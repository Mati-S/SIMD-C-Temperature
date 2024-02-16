# SIMD-C-Temperature
This is a personal college proyect in which the code takes an image and makes a new one by repleacing the original colors with it's temperature.

The idea behind this proyect is to make image filters only using C and Assembler for Linux based OS and learning the use of SIMD in conjunction with regular instructions and C.
I wanted to learn how to create and modify images by taking each pixel information (RGBA values) and translating them to simple temperature measurments in order to create a new image using this data.
The ecuation i used to retrieve the temperature is the following:
        t_(i,j) = ⌊(src.r_(i,j) + src.g_(i,j) + src.b_(i,j)/3⌋

For an example, it take the following image:

![alt text](https://github.com/Mati-S/SIMD-C-Temperature/blob/main/src/img/NoCountryForOldMen.1024x600.bmp?raw=true)

And create a new one with the temperature of the original image, like this:

![alt text](https://github.com/Mati-S/SIMD-C-Temperature/blob/main/src/tests/data/resultados_nuestros/NoCountryForOldMen.1024x600.bmp.temperature.ASM.bmp?raw=true)
