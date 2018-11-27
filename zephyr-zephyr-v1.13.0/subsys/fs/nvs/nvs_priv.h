/*  NVS: non volatile storage in flash
 *
 * Copyright (c) 2018 Laczen
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#ifndef __NVS_PRIV_H_
#define __NVS_PRIV_H_

#ifdef __cplusplus
extern "C" {
#endif

#define SYS_LOG_DOMAIN "fs/nvs"
#define SYS_LOG_LEVEL CONFIG_NVS_LOG_LEVEL
#include <logging/sys_log.h>

/*
 * MASKS AND SHIFT FOR ADDRESSES
 * an address in nvs is an u32_t where:
 *   high 2 bytes represent the sector number
 *   low 2 bytes represent the offset in a sector
 */
#define ADDR_SECT_MASK 0xFFFF0000
#define ADDR_SECT_SHIFT 16
#define ADDR_OFFS_MASK 0x0000FFFF

/*
 * Status return values
 */
#define NVS_STATUS_NOSPACE 1

#define NVS_BLOCK_SIZE 8

/* Allocation Table Entry */
struct nvs_ate {
	u16_t id;	/* data id */
	u16_t offset;	/* data offset in sector */
	u16_t len;	/* data len in sector */
	u8_t part;	/* part of a multipart data - future extension */
	u8_t crc8;	/* crc8 check of the entry */
};

#ifdef __cplusplus
}
#endif

#endif /* __NVS_PRIV_H_ */
