# OCP Delta Lake Open System Firmware

The open system firmware contribution to OCP Delta Lake is hosted in this directory. OCP Delta Lake is a single socket server design based on the 3rd Gen Intel Xeon
Scalable processors, which is referred to as [Delta Lake 1S Server](https://www.opencompute.org/documents/delta-lake-1s-server-design-specification-1v05-pdf). OCP Delta Lake server is a component of multi-node server system [Yosemite-V3](https://www.opencompute.org/documents/ocp-yosemite-v3-platform-design-specification-1v16-pdf).
The open system firmware solution developed for Delta Lake is based on [coreboot](https://coreboot.org/)/[LinuxBoot](https://www.linuxboot.org/) stack. The support status and information of coreboot/LinuxBoot for OCP Delta Lake can be found [here](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md). Please note that the support status described in the link was developed and validated against an engineering Intel FSP which is not public, but it shouldn't be a huge gap to work on the current upstream coreboot to reach the same status with the public Intel FSP. If you need professional service for this effort or other features development, please see [Maintainers and Professional Support](#Maintainers-and-Professional-Support). The files in this directory can help you download all the public source code and binary files, and build the final system firmware image that can pass [OCP OSF checklist](https://www.opencompute.org/wiki/Open_System_Firmware/Checklist). You can find the Delta Lake OSF checklist at Wiwynn/deltalake/Open System Firmware Requirements Checklist (v1.2).xlsx. In the patch file in src directory, config-deltalake.json configures all the open source upstream repositories and commit hashes, including the toolchain that will be downloaded and built. For more detail about the fetching and building process please see [How To Build](#How-To-Build).

## Build Pre-requisites

 * Linux OS
 * GNU Make
 * python

## How To Build

    cd Wiwynn/deltalake && ./download_and_build.sh

The download_and_build.sh shell script will clone the necessary repositories and trigger the build process. The [osf-builder](https://github.com/facebookincubator/osf-builder) describes more detail about the fetching and building process for coreboot and LinuxBoot. A built firmware image following the build steps is placed under bin/osf-deltalake.rom.

## Documentation

The [document](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md) provides the support status that has been developed and validated against an enginnering Intel FSP, Server Platform Services, microcode and ACM binaries that are not public but can be obainted under Intel NDA. [Features of firmware](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md#working-features), [how to flash](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md#flashing-coreboot) and [firmware configurations](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md#firmware-configurations) are described in the document.
 * Validation scope: The uploaded image can pass and is compliant to OCP OSF checklist (v1.1) section 6 Test regime, please see the test results for detail. The test report is placed under Wiwynn/deltalake/Wiwynn_OSF_Cooperlake_QE_OCP_Checklist_V1.0_BIOS_v1.0.0_20210908.pdf.
 * Readiness: Pre-production. The OSF is good enough for pre-production entrance on the corresponding OCP platform as-is.

## Tool For User Modification

* Firmware upgrade: same as described in [how to flash](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md#flashing-coreboot).
* Firmware configuration: in LinuxBoot u-root shell, we use [vpdbootmanager](https://github.com/u-root/u-root/tree/master/tools/vpdbootmanager) to get, set, add and delete firmware configurable variables. Please note that the tool may be renamed to 'vpdmgr' in the future. The tool would execute [vpd](https://chromium.googlesource.com/chromiumos/platform/vpd/+/master/README.md) and [flashrom](https://flashrom.org/Flashrom) for flash write operation. For read operation it reads via Linux /sys/firmware/vpd interface provided by selecting Linux kernel CONFIG_GOOGLE_VPD.
    - vpdbootmanager get [variable name]
    - vpdbootmanager set [variable name] [variable value]
    - vpdbootmanager delete [variable name]

## How To Buy OCP Delta Lake

In the near future Yosemite-V3 can be found in [Open Compute Project Marketplace](https://www.opencompute.org/solutions), if you are interested please contact [Wiwynn](https://www.wiwynn.com/contact-wiwynn/).

## Potential Gaps To Use OCP Delta Lake OSF in Production
 * Intel CBnT. CBnT 0T support is in coreboot, but overall solution requires Intel ACM binaries which are available under Intel agreement. 
 * Run time management engine. The OCP OSF Delta Lake code base includes Intel PCH Ignition binary instead of Server Platform Services (SPS) binary, this means there is no run time service from management engine. Intel SPS binary is available under Intel agreement. 
 * Hardware error handling. coreboot patches related to hardware error injection/handling are not present in the public OCP OSF Delta Lake codebase as they involve Intel IPs. Those patches can not be posted in public.
 * GRUB BootLoaderSpec-style configuration (BLSCFG). The current [localboot](https://github.com/u-root/u-root/tree/master/pkg/boot/localboot) u-root package does not support BLSCFG, you need to make sure your GRUB doesn't enable it. On CentOS 8, you can disable it by modifying /etc/default/grub and set GRUB_ENABLE_BLSCFG=false, and then update the grub configuration by running 'grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg'. There are other u-root packages that support BLSCFG and we are planning to switch to other better maintained package in the near future.

Nevertheless, the above features can be enabled. Please see [Maintainers and Professional Support](#Maintainers-and-Professional-Support).

## Maintainers and Professional Support

For more advanced server features such as Intel CBnT, RAS features for hardware error handling, feature customization and more, those may require Intel NDA information and professional support, please contact [9elements Cyber Security](https://9esec.io/contact) and work with Intel to obain the necessary NDA information.
