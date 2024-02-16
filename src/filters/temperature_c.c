
#include <math.h>
#include "../simd.h"


bool between(unsigned int val, unsigned int a, unsigned int b){
	return a <= val && val < b;
}

void temperature_c (unsigned char *src, unsigned char *dst, int width, int height, int src_row_size, int dst_row_size) {
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i_d = 0, i_s = 0; i_d < height; i_d++, i_s++) {
        for (int j_d = 0, j_s = 0; j_d < width; j_d++, j_s++) {
            bgra_t *p_d = (bgra_t*)&dst_matrix[i_d][j_d*4];
            bgra_t *p_s = (bgra_t*)&src_matrix[i_s][j_s*4];
            int temperature = (p_s->r + p_s->g + p_s->b) / 3;
            bgra_t color;

            if (temperature < 32) {
                color.r = 128 + (temperature * 4);
                color.g = 0;
                color.b = 0;
                color.a = 255;
            } else if (between(temperature, 32, 96)) {
                color.r = 0;
                color.g = (temperature - 32) * 4;
                color.b = 255;
                color.a = 255;
            } else if (between(temperature, 96, 160)) {
                color.r = 255 - ((temperature - 96) * 4);
                color.g = 255;
                color.b = (temperature - 96) * 4;
                color.a = 255;
            } else if (between(temperature, 160, 224)) {
                color.r = 255;
                color.g = 255 - ((temperature - 160) * 4);
                color.b = 0;
                color.a = 255;
            } else {
                color.r = 0;
                color.g = 0;
                color.b = 255 - ((temperature - 224) * 4);
                color.a = 255;
            }
            *p_d = color;
        }
    }
}




