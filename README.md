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
git clone https://github.com/Theoriz/AugmentaP5.git
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

In [Processing][], start your example

```
File -> Examples... -> Contributed Libraries -> AugmentaP5
```

### Basic example

Receive and draw Augmenta data without any other library

// TODO add screenshot (insert basic view)

### 2D and 3D examples

Examples for receiving and drawing Augmenta data including a Syphon output (Mac only) and a basic UI

Install the needed libraries first :

```
Sketch -> Import Library... -> Add Library -> Syphon by Andres Colubri
Sketch -> Import Library... -> Add Library -> ControlP5
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
Sketch -> Import Library... -> Add Library -> ControlP5
```

Documentation
-------------

Protocol is described here : https://github.com/Theoriz/Augmenta/wiki

Documentation can be found in the reference folder

Here is a presentation explaining how to use the API

http://fr.slideshare.net/theoriz/augmentap5-api

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
