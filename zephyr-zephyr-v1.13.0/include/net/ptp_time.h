/*
 * Copyright (c) 2018 Intel Corporation.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @file
 * @brief Public functions for the Precision Time Protocol time specification.
 *
 */

#ifndef __PTP_TIME_H
#define __PTP_TIME_H

/**
 * @brief Precision Time Protocol time specification
 * @defgroup ptp_time PTP time
 * @ingroup networking
 * @{
 */

#include <net/net_core.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Precision Time Protocol Timestamp format.
 *
 * This structure represents a timestamp according
 * to the Precision Time Protocol standard.
 *
 * Seconds are encoded as a 48 bits unsigned integer.
 * Nanoseconds are encoded as a 32 bits unsigned integer.
 */
struct net_ptp_time {
	/** Seconds encoded on 48 bits. */
	union {
		struct {
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
			u32_t low;
			u16_t high;
			u16_t unused;
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
			u16_t unused;
			u16_t high;
			u32_t low;
#else
#error "Unknown byte order"
#endif
		} _sec;
		u64_t second;
	};

	/** Nanoseconds. */
	u32_t nanosecond;
};

#ifdef __cplusplus
}
#endif

/**
 * @}
 */

#endif /* __PTP_TIME_H */
