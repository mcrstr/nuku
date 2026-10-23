/* helper for the Pascal SNDTEST: same diagnostics as SBDIAG */
#include <stdio.h>
#include <mikmod.h>
#include "dos/dossb.h"
void sbinfo_static(char *buf) {
	sprintf(buf, "SB port %x irq %d dma8 %d dma16 %d dsp %x caps %x",
	        sb.port, sb.irq, sb.dma8, sb.dma16, sb.dspver, sb.caps);
}
void sbinfo_buffer(char *buf) {
	if (!sb.dma_buff) { sprintf(buf, "DMA buffer: none"); return; }
	sprintf(buf, "DMA buffer: channel %d physical %lx size %u",
	        sb.dma_buff->channel, sb.dma_buff->physical, sb.dma_buff->size);
}
void sbinfo_live(char *buf) {
	unsigned int size = 0, pos = 0;
	if (sb.dma_buff) sb_query_dma(&size, &pos);
	sprintf(buf, "irqs=%d  dma_pos=%u/%u", sb.irqcount, pos, size);
}
