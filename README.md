Augmenta for Processing
=======================

A [Processing][] Augmenta helper library and examples maintained by [Théoriz studio][]

Install
-------

Open [Processing][] and install the OscP5 library

```
Sketch -> Import Library... -> Add Library -> OscP5 by Andreas Schlegel
```

Then get AugmentaP5 library from here

      https://github.com/Lyptik/AugmentaP5/archive/master.zip (and rename to AugmentaP5)

or

```
git clone https://github.com/Lyptik/AugmentaP5.git
```

in the following directory

- Mac OSX : /Users/Username/Documents/Processing/libraries
- Windows : C:/My Documents/Processing/libraries
- Linux   : /home/Username/sketchbook/libraries

You should now have a folder named *AugmentaP5* in this directory.

Then restart [Processing][]

Use
---
In [Processing][]

```
Sketch -> Import Library... -> OscP5 (needed dependency)
Sketch -> Import Library... -> AugmentaP5
```

Examples
--------

### Basic example

Receive and draw Augmenta data without any other library

// TODO add screenshot (insert basic view)

### 2D and 3D examples

Examples for receiving and drawing Augmenta data including a Syphon output (Mac only) and a basic UI

Install the needed libraries first :

```
Sketch -> Import Library... -> Add Library -> Syphon by Andres Colubri
Sketch -> Import Library... -> Add Library -> G4P by Peter Lager
Sketch -> Import Library... -> Add Library -> PeasyCam by Jonathan Feinberg (for the 3D example only)
```

### Assets

Full 2D example including various features you may find useful :
- Display points representing people and lines between them
- [Audioreaction] Change the radius of the circle depending on a sound input
- [Sprites] Add an image under people's feet
- [Video] Play a video in the background
- [Sound] Play a sound when a person enters the scene
- [Triggers] Sends a message when a person enters/leaves the trigger area and allows to get a list of the people inside it at any time (shapes available : circles, rectangles, complex polygons)

Install the needed libraries first :

```
Sketch -> Import Library... -> Add Library -> Syphon by Andres Colubri
Sketch -> Import Library... -> Add Library -> G4P by Peter Lager
Sketch -> Import Library... -> Minim
Sketch -> Import Library... -> Video
```


### Mouse sender

Sketch that emulates and sends a virtual person that you can control with your mouse.
This allows you to test the examples

Data
----

```
    * Augmenta OSC Protocol :

        /au/personWillLeave args0 arg1 ... argn
        /au/personUpdated   args0 arg1 ... argn
        /au/personEntered   args0 arg1 ... argn

        where args are :

        
        0: pid (int)                        // Personal ID ex : 42th person to enter stage has pid=42
        1: oid (int)                        // Ordered ID ex : if 3 person on stage, 43th person has oid=2
        2: age (int)                        // Time on stage (in frame number)
        3: centroid.x (float)               // Position projected to the ground
        4: centroid.y (float)               
        5: velocity.x (float)               // Speed and direction vector
        6: velocity.y (float)
        7: depth (float)                    // Distance to sensor (in m)
        8: boundingRect.x (float)           // Bounding box on the ground
        9: boundingRect.y (float)
        10: boundingRect.width (float)
        11: boundingRect.height (float)
        12: highest.x (float)               // Highest point placement
        13: highest.y (float)
        14: highest.z (float)               // Height

        /au/scene/   args0 arg1 ... argn

        0: currentTime (int)                // Time (in frame number)
        1: percentCovered (float)           // Percent covered
        2: numPeople (int)                  // Number of person
        3: averageMotion.x (float)          // Average motion
        4: averageMotion.y (float)
        5: scene.width (int)                // Scene size
        6: scene.height (int)
```

Contribute
----------

Check [TODO](TODO.md) and [TOFIX](TOFIX.md), then get [Eclipse][] to modify this library.

Instructions are here : [https://github.com/processing/processing-library-template](https://github.com/processing/processing-library-template)

Thanks
------

Thanks to the guys at [OpenTSPS][], this library is heavily inspired from it.

Thanks to the devs and beta testers whose contribution are vitals to the project
 Tom Duchêne / David-Alexandre Chanel / Jonathan Richer / you !

[Processing]: http://www.processing.org/
[Théoriz studio]: http://www.theoriz.com/
[OpenTSPS]: https://github.com/labatrockwell/openTSPS/
[Eclipse]: http://www.eclipse.org/
