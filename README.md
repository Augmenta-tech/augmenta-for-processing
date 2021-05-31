# Augmenta for Processing

A [Processing][] helper library and examples maintained by [Théoriz studio][] that allows to use the [Augmenta][] tracking system.

## Install

Open [Processing][] and install the OscP5 library

```
Sketch -> Import Library... -> Add Library -> OscP5
```

### Auto installation

**Coming soon:** You can get the *Augmenta for Processing* library within the Processing editor, in Sketch>import a library...>add a library... search for "Augmenta for Processing" and add it to your Processing editor. This is the prefered way of installing it.

### Manual installation

You can also download it manually:

get the library on github at this address: https://github.com/Theoriz/augmenta-for-processing/archive/refs/heads/master.zip and **rename it "Augmenta"**.

or

```
git clone https://github.com/Theoriz/augmenta-for-processing.git
```

Once you have downloaded the library and **renamed it "Augmenta"**, put it in the following directory

- Mac OSX : /Users/Username/Documents/Processing/libraries
- Windows : C:/My Documents/Processing/libraries
- Linux   : /home/Username/sketchbook/libraries

You should now have a folder named **Augmenta** in this directory.

Then restart [Processing][]

## Usage

In [Processing][]

```
Sketch -> Import Library... -> OscP5 (needed dependency)
Sketch -> Import Library... -> Augmenta for Processing
```

## Examples

In [Processing][], start your example

```
File -> Examples... -> Contributed Libraries -> Augmenta for Processing
```

### Basic example

Receive and draw Augmenta data without any other library

### 2D and 3D examples

Examples for receiving and drawing Augmenta data including a Syphon/Spout output (Mac/Windows only) and a basic UI

Install the available libraries first :

```
Sketch -> Import Library... -> Add Library -> Syphon
Sketch -> Import Library... -> Add Library -> Spout For Processing
Sketch -> Import Library... -> Add Library -> ControlP5
Sketch -> Import Library... -> Add Library -> PeasyCam (for the 3D example only)
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
Sketch -> Import Library... -> Add Library -> Syphon
Sketch -> Import Library... -> Add Library -> Spout For Processing
Sketch -> Import Library... -> Add Library -> ControlP5
Sketch -> Import Library... -> Add Library -> Minim
Sketch -> Import Library... -> Add Library -> Video
```

Documentation
-------------

Data protocol is here : https://github.com/Theoriz/Augmenta/wiki

Here is a presentation explaining how to use the API with an older version of the library. Some methods/members names have changed but the main concepts remain the same.

http://fr.slideshare.net/DavidAlexandreCHANEL/augmentap5-api-59334230

Contribute
----------

Fork and submit pull requests. Get [Eclipse][] to modify the library.

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
[Augmenta]: https://augmenta-tech.com