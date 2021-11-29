# OCP Mono Lake Open System Firmware

The open system firmware contribution to the OCP Mono Lake is a single socket server designed based on the Broadwell-DE Intel processor which is referred to as [Mono Lake 1s Server](https://www.opencompute.org/documents/mono-lake-1s-server-design-v04-intel-xeon-d-1500) The Mono Lake was originally contributed to OCP by Facebook in 2016 and further worked on by Sesame by ITRenew Inc.

The OCP Mono Lake is a component of a multi-node server system [Yosemite-V1](https://www.opencompute.org/documents/multi-node-server-platform-yosemite-v05) that was also originally contributed by Facebook but left untouched.

The open system firmware solution developed Mono Lake is based on [coreboot](https://coreboot.org)/[LinuxBoot](https://www.linuxboot.org/) and [u-root](https://u-root.org/). You can find the support status and information of support for coreboot and linuxboot [here](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/monolake.md)

Please note that the support status described in the link was developed and validated against an engineering Intel FSP which is not public, but was worked on by Syspro who owns the distribution rights. There is a public FSP available that supports the Broadwell-DE processor but has some significant shortcomings to be used in a production environment. If you need professional service for the Mono Lake platform or platform development, please see [Maintainers and Professional Support](#Maintainers-and-Professional-Support). The files in this directory can help you download all the public source and binary files and build the final system firmware image that can pass [OCP OSF Checklist](https://opencompute.org/wiki/Open_System_Firmware/Checklist).

You can find the Mono Lake OSF check list at Sesame/monolake/Open System Firmware Requirements Checklist (v1.2).xlsx.You can use the bash scripts to download all the pre-requisites and build the Mono Lake firmware coreboot image. For more details on how to fetch the sources and build the firmware, please see [How to Build](#How-To-Build).


## Build Pre-requisites

 * Ubuntu 20.04 LTS
 * GNU Make
 * python
 * Bash
 * Broadwell-DE FSP (see below for how to obtain) binary
 * Intel Management Engine binary (see below how to obtain)

## How To Build

    cd Sesame/monolake 
    ./osf_build_monolake.sh

The resultant coreboot image should be visible in the same directory as the bash script.


## Documentation

The [document](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/monolake.md) provides the support status that has been developed and validated against an engineering Intel FSP, Server Platform Services, microcode and ACM binaries that are not public but can be obainted under Intel NDA. [Features of firmware](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/coreboot.md#working-features), [how to flash](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md#flashing-coreboot) and [firmware configurations](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/deltalake.md#firmware-configurations) are described in the document.
 * Validation scope: The uploaded image can pass and is compliant to OCP OSF checklist (v1.1) section 6 Test regime, please see the test results for detail. The test report is placed under Sesame/Mono_Lake/Sesame_OSF_Broadwell_DE_OCP_Checklist_V1.0_BIOS_v1.0.0_20210908.pdf.
 * Readiness: Pre-production. The OSF is good enough for pre-production entrance on the corresponding OCP platform as-is.

## Tool For User Modification

* Firmware upgrade: same as described in [how to flash](https://github.com/coreboot/coreboot/blob/master/Documentation/mainboard/ocp/monolake.md#flashing-coreboot).
* Firmware configuration: in LinuxBoot u-root shell, we use [vpdbootmanager](https://github.com/u-root/u-root/tree/master/tools/vpdbootmanager) to get, set, add and delete firmware configurable variables. Please note that the tool may be renamed to 'vpdmgr' in the future. The tool would execute [vpd](https://chromium.googlesource.com/chromiumos/platform/vpd/+/master/README.md) and [flashrom](https://flashrom.org/Flashrom) for flash write operation. For read operation it reads via Linux /sys/firmware/vpd interface provided by selecting Linux kernel CONFIG_GOOGLE_VPD.
    - vpdbootmanager get [variable name]
    - vpdbootmanager set [variable name] [variable value]
    - vpdbootmanager delete [variable name]

## How To Buy OCP Mono Lake

The Yosemite-V1 with Mono Lake is already available from [Sesame by ITRenew Inc](https://sesame.com/) for purchase. All included firmware will be available. If you are interested in the Mono Lake platform, please contact [Sesame by ITRenew Inc](https://www.itrenew.com/contact/)

## Potential Gaps To Use OCP Mono Lake OSF in Production
 * Only the Facebook version of OpenBMC is available on the Mono Lake. To use the Linux Foundation OpenBMC will require some effort to do so. Please see [Maintainers and Professional Support](#Maintainers-and-Professional-Support)
 * While possible to use the public FSP for Broadwell DE, the FSP is limited and not considered at a quality to be well supported. The updated FSP was developed and distributed under Intel license by [SysPro Consulting](https://www.sysproconsulting.com/)
 * Run time management engine. The OCP OSF Mono Lake code base only supports Server Platform Services (SPS) binary. Intel SPS binary is available under Intel agreement. 


Nevertheless, the above features can be enabled. Please see [Maintainers and Professional Support](#Maintainers-and-Professional-Support).

## Maintainers and Professional Support

For more advanced features and customization - those might require Intel NDA information and professional support either through [Sesame by ITRenew](https://sesame.com) or through [SysPro Consulting](https://sysproconsulting.com)
