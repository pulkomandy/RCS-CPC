# RCS (Reverse Computer Screen)

**RCS** is an utility to reorder bytes from Amstrad CPC screens before compression.

Technically, the Amstrad CPC screen can be divided in blocks of 8 raster lines
or considered as a very large, 8 pixel high image, that is displayed by wrapping around.

**RCS** reorders bytes as vertical stripes. If you apply **RCS** encoding before compression,
the obtained compression ratio should be at least 10% better than usual.


## Usage

To apply **RCS** encoding to a file, use the command-line utility as follows:

```
rcs Cobra.scr
```

This will generate a **RCS** encoded file called "Cobra.scr.rcs", that you must now
compress using your favorite compressor (such as [ZX0](https://github.com/einar-saukas/ZX0),
[ZX1](https://github.com/einar-saukas/ZX1), 
or [ZX7](https://spectrumcomputing.co.uk/entry/27996/ZX-Spectrum/ZX7)).

Afterwards, you have the following choices to restore the original screen from
the compressed data:

(The below options are not yet available for the Amstrad CPC version)

* First decompress it to a temporary buffer, then use a "buffered **RCS** decoder"
  to decode it to the screen. In this case, there are 2 variants of this routine
  that you can choose: "compact" (that's very small) or "rapid" (about 2.5 times
  faster). However this option requires a 16384 bytes buffer to decompress a full 
  screen, therefore this is a good choice only if your program is already using a 
  large buffer area (such as double buffer) anyway.

* First decompress it directly to the screen, then use "on-screen **RCS** decoder"
  to decode it. However this option will display some "garbage" on screen for
  a fraction of a second (unless you compress bitmaps and attributes separately,
  so you can hide the screen using the same INK/PAPER, decompress bitmaps only,
  decode it, then finally decompress attributes).

* Decompress and decode at the same time, directly to the screen, using a "Smart" 
  integrated decompressor (either **RCS+ZX0**, **RCS+ZX1**, or **RCS+ZX7**). When
  decompressing anything to the screen area, the "Smart" version assumes the
  compressed data was also **RCS** encoded, so it automatically decodes it. When
  decompressing to anywhere else, it assumes the compressed data is not **RCS**
  encoded, thus it works exactly like regular **ZX0**, **ZX1** or **ZX7**
  decompressors. However this option only works for currently supported compressors
  (**ZX0**, **ZX1**, and **ZX7**), and the "Smart" version is about 3 times slower
  than standard **ZX0**, **ZX1**, or **ZX7** decompressors.

* Decompress and decode at the same time, directly to the screen, using the "Agile"
  integrated decompressor (either **RCS+ZX0**, **RCS+ZX1**, or **RCS+ZX7**). It
  works exactly the same as "Smart" version, except it runs much faster (about the
  same speed as regular "Turbo" decompressor) when decompressing data outside the
  screen (without **RCS**). However the "Agile" decompressor version is larger than
  "Smart".


## Partial Screens

Currently not supported on CPC. It could be done in multiple of 8 lines by adjusting the limit for
the K/col value to something less than the entire memory. For example, 0x40f instead of 0x800 to
fill only half the screen.

## Custom width

The CPC hardware allows to change the width of the display. Use the -w option to tell the
compressor how large your screen is (in bytes). The decompressor also needs the same value.

It's possible to reorder pictures using a width value not matching the picture display size,
but the compression improvement won't be as good.

## Why does this work?

Reordering the bytes improves data locality. Consecutive bytes in a vertical stripe are more
likely to be similar to each other because they are just 1 pixel away from each other. Consecutive
bytes in a line are 8 pixels away (if you consider same-position bit in each byte), and lines are
also not consecutive in the native format.

## Tech Stuff

The following program helps visualize the regular ZX Spectrum screen ordering:

```
    10 MODE 1
    20 FOR F=0 TO 16383
    30 POKE &C000+F,255
    40 NEXT F
```

The **RCS** format reorganizes this data as follows:

```
    10 MODE 1
    20 J=0:K=0:L=0:WIDTH=80
    20 FOR I=0 TO 16383
    30 POKE &C000+J,255
    40 J=J+&800
    50 IF J>&3FFF THEN K=K+WIDTH:J=K
    60 IF K>&7FF THEN L=L+1;K=L:J=K
    70 NEXT I
```


## License

This utility can be used freely within your own Amstrad CPC programs, even for
commercial releases. The only condition is that you indicate somehow in your
documentation that you have used **RCS**.


## Credits

**RCS** was created by **Einar Saukas**.

Many thanks to **joefish** for suggesting to implement the "on screen" decoder,
  **Antonio Villena** for additional suggestions to improve it, and
  **James 'Arkannoyed' Slasor** for providing the compact version of
  the "buffered" RCS decoder.

**RCS-CPC** C code by **PulkoMandy**.
