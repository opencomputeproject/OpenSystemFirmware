# Open System Firmware (OSF)

This repository holds software contributions for OSF.

> To make it easy for customers to recreate firmware, ODMs SHALL document where
> the various components are and how to build a complete firmware image. These
> documents, instructions, and (e.g.) makefiles SHALL be placed in the repos
> shown below; however, we do not require that the entirety of (e.g.) the source
> code be copied into these repos. For example, if an ODM is using coreboot or
> Linux, source code SHALL be upstreamed to those projects. The OCP repos can
> then contain configuration files and, almost certainly, a git hash of the
> version of the software used. Binary artifacts SHOULD be placed in the OCP
> repos, as well as a link to the source of the binary(ies), and a license
> document.

| Location | Description |
| -------- | ----------- |
| `[vendor_name]/[product_name]/[version]/` | Directory of OSF product |
| `[vendor_name]/[product_name]/[version]/LICENSE` | License for this directory |
| `[vendor_name]/[product_name]/[version]/Makefile` | Script to build OSF product |
| `[vendor_name]/[product_name]/[version]/src/` | Directory for source files |
| `[vendor_name]/[product_name]/[version]/bin/` | Directory for binary files |

See [Open System Firmware Checklist](https://www.opencompute.org/wiki/Open_System_Firmware/Checklist) for
submission process.
