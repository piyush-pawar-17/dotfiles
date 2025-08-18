import { useState, useEffect } from "react";
import * as zebar from "zebar";
import {
  Terminal,
  ArrowRightLeft,
  ArrowUpDown,
  Cable,
  Wifi,
  WifiHigh,
  WifiLow,
  WifiZero,
  WifiCog,
  WifiOff,
  Microchip,
  Cpu,
  Battery,
  BatteryWarning,
  BatteryLow,
  BatteryMedium,
  BatteryFull,
  BatteryCharging,
} from "lucide-react";

const providers = zebar.createProviderGroup({
  network: { type: "network" },
  glazewm: { type: "glazewm" },
  cpu: { type: "cpu" },
  date: { type: "date", formatting: "EEEE, d MMMM yyyy - HH:mm" },
  battery: { type: "battery" },
  memory: { type: "memory" },
});

function App() {
  const [output, setOutput] = useState(providers.outputMap);

  useEffect(() => {
    providers.onOutput(() => setOutput(providers.outputMap));
  }, []);

  function getNetworkIcon(networkOutput) {
    switch (networkOutput.defaultInterface?.type) {
      case "ethernet":
        return <Cable size={14} />;
      case "wifi":
        if (networkOutput.defaultGateway?.signalStrength >= 80) {
          return <Wifi size={14} />;
        } else if (networkOutput.defaultGateway?.signalStrength >= 65) {
          return <WifiHigh size={14} />;
        } else if (networkOutput.defaultGateway?.signalStrength >= 40) {
          return <WifiLow size={14} />;
        } else if (networkOutput.defaultGateway?.signalStrength >= 25) {
          return <WifiZero size={14} />;
        } else {
          return <WifiCog size={14} />;
        }
      default:
        return <WifiOff size={14} />;
    }
  }

  function getBatteryIcon(batteryOutput) {
    if (batteryOutput.chargePercent > 90) return <BatteryFull size={14} />;
    if (batteryOutput.chargePercent > 70) return <BatteryMedium size={14} />;
    if (batteryOutput.chargePercent > 40) return <BatteryLow size={14} />;
    if (batteryOutput.chargePercent > 20) return <BatteryWarning size={14} />;
    return <Battery size={14} />;
  }

  function getWorkspaceColor(workspace, index) {
    if (workspace.hasFocus) {
      return index % 3 === 0
        ? "#cb6868"
        : index % 3 === 1
          ? "#d38b33"
          : "#3e8fb0";
    }

    return index % 3 === 0
      ? "#6e5366"
      : index % 3 === 1
        ? "#725f5d"
        : "#3b506e";
  }

  return (
    <div className="grid gap-2 text-sm h-full grid-cols-[1fr_1fr_1fr] items-center">
      <div className="px-4 h-full w-fit flex items-center">
        <div className="bg-[#393552] shadow-[3px_3px_0px_1px_#2a283e] py-2 px-3 w-fit flex items-center gap-3">
          <Terminal size={16} className="ml-1" />

          {output.network && (
            <>
              <div className="size-1.5 rounded-full bg-white" />

              <div className="flex items-center gap-2">
                {getNetworkIcon(output.network)}
                {output.network.defaultGateway?.ssid}
              </div>
            </>
          )}

          {output.memory && (
            <>
              <div className="size-1.5 rounded-full bg-white" />

              <div className="flex items-center gap-1.5">
                <Microchip size={14} />
                {Math.round(output.memory.usage)}%
              </div>
            </>
          )}

          {output.cpu && (
            <>
              <div className="size-1.5 rounded-full bg-white" />

              <div className="flex items-center gap-1.5">
                <Cpu
                  size={14}
                  className={output.cpu.usage > 85 ? "text-red-300" : ""}
                />
                <span className={output.cpu.usage > 85 ? "text-red-300" : ""}>
                  {Math.round(output.cpu.usage)}%
                </span>
              </div>
            </>
          )}

          {output.battery && (
            <>
              <div className="size-1.5 rounded-full bg-white" />

              <div className="flex items-center gap-1.5">
                {output.battery.isCharging ? (
                  <BatteryCharging size={14} />
                ) : (
                  getBatteryIcon(output.battery)
                )}
                {Math.round(output.battery.chargePercent)}%
              </div>
            </>
          )}
        </div>
      </div>
      <div className="px-4 h-full w-full flex justify-center items-center">
        <div className="bg-[#393552] shadow-[3px_3px_0px_1px_#2a283e] py-2 px-3 w-fit flex items-center gap-1">
          {output.glazewm && (
            <div className="flex gap-2">
              {output.glazewm.currentWorkspaces.map((workspace, index) => (
                <button
                  key={workspace.name}
                  className={`${workspace.hasFocus ? "h-7 w-12" : "size-7"} transition-[width] ease-in-out duration-300 flex items-center cursor-pointer justify-center`}
                  style={{
                    backgroundColor: getWorkspaceColor(workspace, index),
                  }}
                  onClick={() =>
                    output.glazewm.runCommand(
                      `focus --workspace ${workspace.name}`,
                    )
                  }
                >
                  {workspace.displayName ?? workspace.name}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>
      <div className="px-4 h-full w-full flex gap-2 justify-end items-center">
        <div className="bg-[#393552] shadow-[3px_3px_0px_1px_#2a283e] py-2 pl-3 pr-4 w-fit flex items-center gap-3">
          {output.glazewm && (
            <>
              {output.glazewm.bindingModes.map((bindingMode) => (
                <button key={bindingMode.name} className="capitalize mr-2">
                  {bindingMode.displayName ?? bindingMode.name}
                </button>
              ))}

              <button
                className="cursor-pointer hover:bg-[#252338] size-7 flex items-center justify-center"
                onClick={() =>
                  output.glazewm.runCommand("toggle-tiling-direction")
                }
              >
                {output.glazewm.tilingDirection === "horizontal" ? (
                  <ArrowRightLeft size={14} />
                ) : (
                  <ArrowUpDown size={14} />
                )}
              </button>
            </>
          )}

          <div className="size-1.5 rounded-full bg-white" />
          <div>{output.date?.formatted}</div>
        </div>
      </div>
    </div>
  );
}

export default App;
