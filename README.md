# Augmenta for Processing

A [Processing][] helper library and examples maintained by [Théoriz studio][] that allows to use the [Augmenta][] tracking system.

![bandicam 2021-10-28 12-07-53-419](https://user-images.githubusercontent.com/64955193/139235423-674135df-cbe4-4f8a-be8f-51eb74a41d0e.gif)



## Install

Open [Processing][] and install the OscP5 and Augmenta library
```
Sketch -> Import Library... -> Add Library -> OscP5
Sketch -> Import Library... -> Add Library -> Augmenta for Processing
```

## Usage

In [Processing][]

```
Sketch -> Import Library... -> OscP5
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
Sketch -> Import Library... -> Add Library -> PeasyCam (3D example only)
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

Data protocol is here : https://github.com/Theoriz/Augmenta/wiki#data

Advanced : Manual install (git)
-------------------------------------

get the library on github at this address: https://github.com/Theoriz/augmenta-for-processing/archive/refs/heads/master.zip and **rename it Augmenta**.

or

```
git clone https://github.com/Theoriz/augmenta-for-processing.git
```

Once you have downloaded the library and **renamed it Augmenta**, put it in the following directory

- Mac OSX : /Users/Username/Documents/Processing/libraries
- Windows : C:/My Documents/Processing/libraries
- Linux   : /home/Username/sketchbook/libraries

You should now have a folder named **Augmenta** in this directory.

Then restart [Processing][]

Contribute
----------

Fork and submit pull requests. Get [Eclipse][] to modify the library.

Instructions are here : [https://github.com/processing/processing-library-template](https://github.com/processing/processing-library-template)

Thanks
------

Thanks to the devs and beta testers whose contribution are vitals to the project
Tom Duchêne / David-Alexandre Chanel / Jonathan Richer / Thomas Weissgerber / you !

[Processing]: http://www.processing.org/
[Théoriz studio]: http://www.theoriz.com/
[OpenTSPS]: https://github.com/labatrockwell/openTSPS/
[Eclipse]: http://www.eclipse.org/
[Augmenta]: https://augmenta-tech.com
