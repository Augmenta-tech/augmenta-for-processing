Augmenta for Processing
=======================

A [Processing][] Augmenta helper library and examples maintained by [Théoriz][].

Installation
------------

We assume that you have [Processing][] installed.

```
git clone https://github.com/Username/AugmentaP5.git or download library
```

On Mac OSX

```
/Users/Username/Documents/Processing
```

On Windows

```bash
C:/My Documents/Processing/
```

Then restart [Processing][].

Importing Augmenta to your sketch
---------------------------------

```
Sketch -> Import Library... -> AugmentaP5
```

Examples
--------

### Basic example

Receive and draw Augmenta basic data

// TODO add screenshot (insert basic view)

Dependency
OscP5 by Andreas Schlegel

### 2D and 3D example

Full example receiving and drawing Augmenta data

* Dependencies :

- OscP5 by Andreas Schlegel
- Syphon by Andres Colubri
- G4P by Peter Lager
- PeasyCam by Jonathan Feinberg (needed for the 3D example)

// TODO add screenshot (insert 2D and 3D view)

Developping library
-------------------

You need [Eclipse][] to modify this library

// TODO : add help to launch eclipse

Protocol
--------

```
    * Augmenta OSC Protocol :

        /au/personWillLeave/ args0 arg1 ... argn
        /au/personUpdated/   args0 arg1 ... argn
        /au/personEntered/   args0 arg1 ... argn

        where args are :

        0: pid (int)
        1: oid (int)
        2: age (int)
        3: centroid.x (float)
        4: centroid.y (float)
        5: velocity.x (float)
        6: velocity.y (float)
        7: depth      (float)
        8: boundingRect.x (float)
        9: boundingRect.y (float)
        10: boundingRect.width  (float)
        11: boundingRect.height (float)
        12: highest.x (float)
        13: highest.y (float)
        14: highest.z (float)

        /au/scene/   args0 arg1 ... argn

        0: currentTime (int)
        1: percentCovered (float)
        2: numPeople (int)
        3: averageMotion.x (float)
        4: averageMotion.y (float)
        5: scene.width (int)
        6: scene.height (int)
```

Thanks
------

Thanks to the guys at [OpenTSPS][], this library is heavily inspired from it.

[Processing]: http://www.processing.org/
[Théoriz]: http://www.theoriz.com/
[OpenTSPS]: https://github.com/labatrockwell/openTSPS/
[Eclipse]: http://www.eclipse.org/
