-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local capabilities = require "st.capabilities"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local PowerConfiguration = zcl_clusters.PowerConfiguration
local utils = require "st.utils"

local ZIGBEE_MOTION_SENSOR_FINGERPRINTS = {
  { mfr = "Third Reality, Inc", model = "3RMS16BZ"},
  { mfr = "THIRDREALITY", model = "3RMS16BZ"}
}

local is_third_reality_motion_sensor = function(opts, driver, device)
  for _, fingerprint in ipairs(ZIGBEE_MOTION_SENSOR_FINGERPRINTS) do
      if device:get_manufacturer() == fingerprint.mfr and device:get_model() == fingerprint.model then
          return true
      end
  end
  return false
end

local function battery_percentage_handler(driver, device, raw_value, zb_rx)
  -- if ((manufacturer == "Third Reality, Inc" || manufacturer == "THIRDREALITY") && application.toInteger() <= 17) {
  local percentage = utils.clamp_value(raw_value.value, 0, 100)
  device:emit_event(capabilities.battery.battery(percentage))
end

local third_reality_motion_sensor = {
  NAME = "Third reality motion sensor",
  zigbee_handlers = {
    attr = {
      [PowerConfiguration.ID] = {
        [PowerConfiguration.attributes.BatteryPercentageRemaining.ID] = battery_percentage_handler
      }
    }
  },
  can_handle = is_third_reality_motion_sensor
}

return third_reality_motion_sensor
