/** @file
 * @brief Network interface promiscuous mode support
 *
 * An API for applications to start listening network traffic.
 * This requires support from network device driver and from application.
 */

/*
 * Copyright (c) 2018 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef __PROMISCUOUS_H
#define __PROMISCUOUS_H

/**
 * @brief Promiscuous mode support.
 * @defgroup promiscuous Promiscuous mode
 * @ingroup networking
 * @{
 */

#include <net/net_pkt.h>
#include <net/net_if.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(CONFIG_NET_PROMISCUOUS_MODE)

/**
 * @brief Start to wait received network packets.
 *
 * @param timeout How long to wait before returning.
 *
 * @return Received net_pkt, NULL if not received any packet.
 */
struct net_pkt *net_promisc_mode_wait_data(s32_t timeout);

/**
 * @brief Enable promiscuous mode for a given network interface.
 *
 * @param iface Network interface
 *
 * @return 0 if ok, <0 if error
 */
int net_promisc_mode_on(struct net_if *iface);

/**
 * @brief Disable promiscuous mode for a given network interface.
 *
 * @param iface Network interface
 *
 * @return 0 if ok, <0 if error
 */
int net_promisc_mode_off(struct net_if *iface);

#else /* CONFIG_NET_PROMISCUOUS_MODE */

static inline struct net_pkt *net_promisc_mode_wait_data(s32_t timeout)
{
	ARG_UNUSED(timeout);

	return NULL;
}

static inline int net_promisc_mode_on(struct net_if *iface)
{
	ARG_UNUSED(iface);

	return -ENOSUP;
}

static inline int net_promisc_mode_off(struct net_if *iface)
{
	ARG_UNUSED(iface);

	return -ENOSUP;
}

#endif /* CONFIG_NET_PROMISCUOUS_MODE */

#ifdef __cplusplus
}
#endif

/**
 * @}
 */

#endif /* __PROMISCUOUS_H */
