# Interactive Bezier Curves (4th degree) Intel x86_64 Assembly
Program is built using make, to build type ```make all``` in terminal
After running click anywhere on the screen to generate a point, after 5 points, bitmap will be reset back to 1.
After closing the bitmap is saved to ```reult.bmp```

# Used general purpose registers
- RDI: pointer to start of pixel data (function argument)
- RSI: point counter (function argument)
- RBX: x coords array pointer (function argument)
- RCX: y coords array pointer (function argument)
- R9D: color value

Image height is stored on stack at ```EBP-8``` and used only at the end

# Used floating point registers
- XMM0: t
- XMM1: step
- XMM2: const 1
