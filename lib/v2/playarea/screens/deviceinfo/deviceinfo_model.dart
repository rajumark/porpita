class BasicDeviceInfo {
  final String deviceName;
  final String manufacturer;
  final String codename;
  final String androidVersion;
  final String sdkVersion;
  final String buildFingerprint;
  final String securityPatch;
  final String serialNumber;
  final String batteryLevel;
  final String batteryStatus;
  final String batteryHealth;
  final String batteryTemp;
  final String batteryTech;
  final String deviceUptime;
  final String rootStatus;
  final String screenResolution;
  final String screenDensity;
  final String cpuAbi;
  final String ramTotal;
  final String ramFree;
  final String internalStorageTotal;
  final String internalStorageFree;
  final String ipAddress;
  final String wifiState;
  final String usbDebugging;

  const BasicDeviceInfo({
    this.deviceName = '—',
    this.manufacturer = '—',
    this.codename = '—',
    this.androidVersion = '—',
    this.sdkVersion = '—',
    this.buildFingerprint = '—',
    this.securityPatch = '—',
    this.serialNumber = '—',
    this.batteryLevel = '—',
    this.batteryStatus = '—',
    this.batteryHealth = '—',
    this.batteryTemp = '—',
    this.batteryTech = '—',
    this.deviceUptime = '—',
    this.rootStatus = '—',
    this.screenResolution = '—',
    this.screenDensity = '—',
    this.cpuAbi = '—',
    this.ramTotal = '—',
    this.ramFree = '—',
    this.internalStorageTotal = '—',
    this.internalStorageFree = '—',
    this.ipAddress = '—',
    this.wifiState = '—',
    this.usbDebugging = '—',
  });
}

class AdvancedDeviceInfo {
  final String kernelVersion;
  final String bootloaderVersion;
  final String basebandVersion;
  final String selinuxStatus;
  final String encryptionState;
  final String trebleSupport;
  final String verifiedBoot;
  final String cpuModel;
  final String cpuCores;
  final String cpuFrequency;
  final String ramUsed;
  final String lowMemoryState;
  final String refreshRate;
  final String displayState;
  final String orientation;
  final String wifiSsid;
  final String mobileNetwork;
  final String airplaneMode;
  final String dnsServers;
  final String sensorCount;
  final String gpuModel;
  final String openGlVersion;
  final String vulkanSupport;
  final String runningProcesses;
  final String foregroundApp;
  final String installedAppsCount;
  final String logcatBufferSize;

  const AdvancedDeviceInfo({
    this.kernelVersion = '—',
    this.bootloaderVersion = '—',
    this.basebandVersion = '—',
    this.selinuxStatus = '—',
    this.encryptionState = '—',
    this.trebleSupport = '—',
    this.verifiedBoot = '—',
    this.cpuModel = '—',
    this.cpuCores = '—',
    this.cpuFrequency = '—',
    this.ramUsed = '—',
    this.lowMemoryState = '—',
    this.refreshRate = '—',
    this.displayState = '—',
    this.orientation = '—',
    this.wifiSsid = '—',
    this.mobileNetwork = '—',
    this.airplaneMode = '—',
    this.dnsServers = '—',
    this.sensorCount = '—',
    this.gpuModel = '—',
    this.openGlVersion = '—',
    this.vulkanSupport = '—',
    this.runningProcesses = '—',
    this.foregroundApp = '—',
    this.installedAppsCount = '—',
    this.logcatBufferSize = '—',
  });
}

class DeviceInfo {
  final BasicDeviceInfo basic;
  final AdvancedDeviceInfo advanced;

  const DeviceInfo({this.basic = const BasicDeviceInfo(), this.advanced = const AdvancedDeviceInfo()});
}
