local json = require "util.json";
local http = require "net.http";
local http_post_with_retry = module:require "util".http_post_with_retry;

-- invite will perform the trigger for external call invites.
-- This trigger is left unimplemented. The implementation is expected
-- to be specific to the deployment.
local function invite(stanza, url, call_id)
    module:log(
        "warn",
        "A module has been configured that triggers external events."
    )
    module:log("warn", "Implement this lib to trigger external events.")
end

-- cancel will perform the trigger for external call cancellation.
-- This trigger is left unimplemented. The implementation is expected
-- to be specific to the deployment.
local function cancel(stanza, url, reason, call_id)
    module:log(
        "warn",
        "A module has been configured that triggers external events."
    )
    module:log("warn", "Implement this lib to trigger external events.")
end

-- missed will perform the trigger for external call missed notification.
-- This trigger is left unimplemented. The implementation is expected
-- to be specific to the deployment.
local function missed(stanza, call_id)
    module:log(
        "warn",
        "A module has been configured that triggers external events."
    )
    module:log("warn", "Implement this lib to trigger external events.")
end


-- Extracts roomName from jid string (everything before "@")
function extract_room(jid)
  local atpos = string.find(jid, "@") or 1
  return string.sub(jid, 0, atpos-1)
end

-- extracts the "nick" values from occupant_joined
local function get_occupant_nick(occupant)
  local name
  local tags = occupant.sessions[occupant.jid].tags
  for i, tagarr in pairs(tags) do
    for tag, tagobj1 in pairs(tagarr) do
      if tag == "name" and tags[i].name == "nick" then 
        name = tags[i]
      end
    end
  end

  return name
end

-- Helper function to http post room stats to Annolens API
-- needs variables from etc/prosody/conf.avail/<server>.cfg.lua :
--   Component "speakerstats.<server>" "speakerstats_component"
--     muc_component = "conference.<server>"
--     stats_server_url_prefix = "https://<server>/api/meetings/byroomname/"
--     stats_server_secret = "<secret>"
-- "Secret" must match Annolens API config key "meetings.stats.secret"
function send_stats(roomName, path, payload)
  local stats_server_url_prefix = module:get_option_string("stats_server_url_prefix")
  local secret = module:get_option_string("stats_server_secret")
  module:log("debug", "stats_server_url_prefix", stats_server_url_prefix)
  module:log("debug", "secret", secret)
  http_post_with_retry(
    stats_server_url_prefix..roomName.."/"..path, 
    4, 
    json.encode(payload),
    { 
      ["Content-Type"] = "application/json",
      ["stats-secret"] = secret 
    }
  );
end

-- Event that occupant has joined
-- Send participant infos to Annolens API
local function occupant_joined(occupant)
    module:log("debug", "occupant_joined", json.encode(occupant))

    if not starts_with(occupant.jid, "focus") then
      local roomName = extract_room(occupant.nick)
      local payload = {
        jid = occupant.jid,
        roomName = roomName,
        nick = get_occupant_nick(occupant),
        role = occupant.role
      }

      module:log("debug", "payload=", json.encode(payload))
      send_stats(roomName, "occupantjoined", payload)
    end
end

-- Event that room has been created
-- Send stats to Annolens API
local function room_created(room)
    module:log("debug", "room_created", json.encode(room))

    local payload = {
      startTimestampSecs = os.time()
    }
    send_stats(extract_room(room.jid), "startsession", payload)
end

-- Event that speaker stats for a conference are available
-- Send stats to Annolens API
local function speaker_stats(room, speakerStats)
    local now = os.time()
    local created_timestamp = room.created_timestamp or now*1000
    module:log("debug", "Meeting duration (seconds):", now - created_timestamp/1000, "seconds")

    local payload = {
      startTimestampSecs = created_timestamp/1000,
      endTimestampSecs = now,
      durationSecs = now - created_timestamp/1000 or 0,
      speakerStats = room.speakerStats
    }

    module:log("debug", "payload=", json.encode(payload))
    send_stats(extract_room(room.jid), "endsession", payload)
end

local ext_events = {
    missed = missed,
    invite = invite,
    cancel = cancel,
    speaker_stats = speaker_stats,
    room_created = room_created,
    occupant_joined = occupant_joined
}

return ext_events
