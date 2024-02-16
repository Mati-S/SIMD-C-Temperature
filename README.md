# SIMD-C-Temperature
This is a personal college proyect in which the code takes an image and makes a new one by repleacing the original colors with it's temperature.

The idea behind this proyect is to make image filters only using C and Assembler for Linux based OS and learning the use of SIMD in conjunction with regular instructions and C.
I wanted to learn how to create and modify images by taking each pixel information (RGBA values) and translating them to simple temperature measurments in order to create a new image using this data.
The ecuation i used to retrieve the temperature is the following:

$t_{(i,j)} = \left\lfloor \frac{src.r_{(i,j)} + src.g_{(i,j)} + src.b_{(i,j)}}{3} \right\rfloor$

$ \text{dst}(i,j) = \begin{cases}  (0, 0, 128 + t \cdot 4)       & \quad \text{si } n < 32\\  (0, (t - 32) \cdot 4, 255)      & \quad \text{si } 32 \leq t < 96\\  ((t - 96) \cdot 4, 255, 255 - (t - 96) \cdot 4)       & \quad \text{si } 96 \leq t < 160\\ (255, 255 - (t - 160) \cdot 4, 0)       & \quad \text{si } 160 \leq t < 224\\  (255 - (t - 224) \cdot 4, 0, 0)       & \quad \text{en otro caso } n \\  \end{cases}


For an example, it take the following image:

![alt text](https://github.com/Mati-S/SIMD-C-Temperature/blob/main/src/img/NoCountryForOldMen.1024x600.bmp?raw=true)

And create a new one with the temperature of the original image, like this:

![alt text](https://github.com/Mati-S/SIMD-C-Temperature/blob/main/src/tests/data/resultados_nuestros/NoCountryForOldMen.1024x600.bmp.temperature.ASM.bmp?raw=true)
