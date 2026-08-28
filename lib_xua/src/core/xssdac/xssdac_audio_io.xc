#include <xs1.h>
#include <debug_print.h>

#include "xssdac_audio_io.h"
#include "xua_commands.h"

void xssdac_audio_io(chanend c_aud)
{
    unsigned curSamFreq = 0;
    unsigned dsdMode = 0;
    unsigned curSamRes_DAC = 0;

    debug_printf("xssdac_audio_io start\n");

    while (1)
    {
        /*
         * Next sample request
         */
        debug_printf("before request\n");
        outuint(c_aud, 0);
        debug_printf("after request\n");

        if (testct(c_aud))
        {
            unsigned command = inct(c_aud);

            debug_printf("command = %u\n", command);

            switch (command)
            {
                case XUA_AUDCTL_SET_SAMPLE_FREQ:
                    curSamFreq = inuint(c_aud) * AUD_TO_USB_RATIO;
                    debug_printf("sample rate = %u\n", curSamFreq);
                    break;

                case XUA_AUD_SET_AUDIO_START:
                    dsdMode = inuint(c_aud);
                    curSamRes_DAC = inuint(c_aud);

                    debug_printf("audio start: dsd=%u, res=%u\n",
                                 dsdMode, curSamRes_DAC);
                    break;

                case XUA_AUD_SET_AUDIO_STOP:
                    debug_printf("audio stop\n");
                    break;

                default:
                    debug_printf("unknown command = %u\n", command);
                    break;
            }

            /*
             * 今はハードウェア再設定がないので、
             * command処理完了後すぐACKしてよい。
             */
            outct(c_aud, XS1_CT_END);
        }
        else
        {
            /*
             * NUM_USB_CHAN_OUT = 2
             */
            int left  = inuint(c_aud);
            int right = inuint(c_aud);

            /*
             * 今は捨てる
             */
            (void)left;
            (void)right;
        }
    }
}