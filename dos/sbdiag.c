/* SBDIAG: plain DJGPP (C) sound check for the Nuku DOS build.
   Plays LL-NUKTR.IT through libmikmod's Sound Blaster driver and prints
   what the card and the DMA controller are doing.
     SBDIAG       16-bit stereo 22050 Hz (as NUKU.EXE)
     SBDIAG 8     8-bit mono 22050 Hz                                   */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pc.h>
#include <sys/farptr.h>
#include <go32.h>
#include <mikmod.h>
#include "dos/dossb.h"

static unsigned long bios_ticks(void) { return _farpeekl(_dos_ds, 0x46c); }

int main(int argc, char **argv)
{
	MODULE *m;
	SAMPLE *s;
	unsigned long t0, last = (unsigned long)-1, upd = 0;
	int eight = argc > 1 && !strcmp(argv[1], "8");

	printf("SBDIAG (pure DJGPP)  BLASTER=%s\n", getenv("BLASTER") ? getenv("BLASTER") : "(none)");
	MikMod_RegisterAllDrivers();
	MikMod_RegisterAllLoaders();
	md_mode = DMODE_SOFT_MUSIC | DMODE_SOFT_SNDFX | (eight ? 0 : DMODE_16BITS | DMODE_STEREO);
	md_mixfreq = 22050;
	if (MikMod_Init("")) { printf("MikMod_Init failed: %s\n", MikMod_strerror(MikMod_errno)); return 1; }
	printf("driver #%d  mode %d  rate %d\n", md_device, md_mode, md_mixfreq);
	if (md_device == 3) {
		printf("SB port %x irq %d dma8 %d dma16 %d dsp %x caps %x mode %x\n",
		       sb.port, sb.irq, sb.dma8, sb.dma16, sb.dspver, sb.caps, sb.mode);
	}
	m = Player_Load("LL-NUKTR.IT", 64, 0);
	if (!m) { printf("cannot load LL-NUKTR.IT: %s\n", MikMod_strerror(MikMod_errno)); return 1; }
	s = Sample_Load("s1.wav");
	MikMod_SetNumVoices(-1, 2);
	MikMod_EnableOutput();
	Player_Start(m);
	if (md_device == 3 && sb.dma_buff)
		printf("DMA buffer: channel %d physical %lx size %u\n",
		       sb.dma_buff->channel, sb.dma_buff->physical, sb.dma_buff->size);
	printf("Playing 15 s (any key stops)\n");
	t0 = bios_ticks();
	while (bios_ticks() - t0 < 273 && !kbhit()) {
		unsigned long sec = (bios_ticks() - t0) / 18;
		if (sec != last) {
			unsigned int size = 0, pos = 0;
			last = sec;
			if (md_device == 3 && sb.dma_buff) sb_query_dma(&size, &pos);
			printf("%2lu s  updates=%lu  irqs=%d  dma_pos=%u/%u\n",
			       sec, upd, md_device == 3 ? sb.irqcount : -1, pos, size);
			fflush(stdout);
			if (s) Sample_Play(s, 0, 0);
		}
		MikMod_Update();
		upd++;
	}
	while (kbhit()) getkey();
	Player_Stop();
	Player_Free(m);
	MikMod_Exit();
	printf("done\n");
	return 0;
}
