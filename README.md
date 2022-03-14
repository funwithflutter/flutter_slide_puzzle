# Box2D Flutter Slide Puzzle

Here is my submission to the [2022 Flutter Puzzle Hack](https://flutter.dev/events/puzzle-hack).

It uses Box2D physics to create an interesting gameplay mechanic where you need to manage a bit more than a simple slider. The code is all pure Flutter with widgets, animations, and [CustomPaint](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html). It doesn't use any Flutter game engine.

The goal is to fill up the containers with the particles, to be able to see the container's number. Then do the normal Slide Puzzle 🙂.

Need more particles? Press the **RAIN** button, and make it rain. But be careful. You take a time penalty each time.

![](preview.gif)

## Nerd Tools 🤓

Play around with the physics of the game yourself. Set the weight and bounciness (elasticity) of the balls and boxes. Alter gravity. Control the world.

<img width="1414" alt="Screenshot 2022-03-14 at 18 03 44" src="https://user-images.githubusercontent.com/13705472/158223345-2b35cc19-d7dc-4334-bd44-621ed2bc0a4c.png">

## Resources

Below I share some resources that helped me make this game. If there is enough interest from the community, I'd be happy to elaborate a bit more with a YouTube video or article 😃.

Some of the logic to handle the Box2D logic/painting might also be worth extracting to a separate package.

### Base logic
The [base example](https://github.com/VGVentures/slide_puzzle) that Very Good Ventures made is a good starting point, and a lot of that code was used as a starting point for this application. They've made various tutorials and other resources to explain their implementation.

### State management
I chose to use [Riverpod](https://riverpod.dev/) for state management, as Riverpod is awesome 😋 and I'm familiar with it. Unfortunately, I didn't have enough time to clean up everything, and sometimes I opted in for the "hacky" approach to get the game across the finish line. 

### Box2D
> Box2D is a 2D rigid body simulation library for games. Programmers can use it in their games to make objects move in realistic ways and make the game world more interactive. From the game engine's point of view, a physics engine is just a system for procedural animation.

Here I owe a thank you to the [Flame team](https://flame-engine.org/) for making and supporting [Forge2d](https://pub.dev/packages/forge2d).

As a basic summary, you can create a "physical" **world**, add **bodies** to it, and have those bodies interact with physical forces, such as gravity and collisions.

As a Flutter dev, I had to represent this **world** information on screen using Flutter widgets and painting.

Here are some interesting files in this repo that are worth looking at:
- [box2d_flutter.dart](lib/box2d/box2d_flutter.dart) - A class to make handling a Box2D world easier. It contains methods to convert **pixel size** to and from **world size**. Take what is present in the "physical world" and represent it on a screen with certain dimensions.
- [box2d_paint_debug.dart](lib/box2d/box2d_paint_debug.dart) - This was used during the early stage of development to paint world object using a Flutter `CustomPaint`. This class can be expanded a lot more in the form of a package.
- [puzzle_paint.dart](lib/widgets/puzzle_paint.dart) - Paints the boxes and balls to the screen, using logic from, or similar to, the above two files.

### Physics
If you want to delve into more of the physics, I highly recommend [The Nature of Code](https://natureofcode.com/), especially the section on [Physics Libraries](https://natureofcode.com/book/chapter-5-physics-libraries/), a lot of this code inspired what I wrote and helped me understand how to use Box2d.

The [box2d_controller.dart](lib/controllers/box2d_controller.dart) and [box2d_state.dart](lib/state/box2d_state.dart) files puts the above information into a Flutter application.

### Design
Sometimes I can design, and sometimes I can't. This was one of those where I couldn't. 

I took GREAT inspiration from the following [Dribbble design](https://dribbble.com/shots/12995366-Black-Sphere-Create-3D-object-in-Figma), made by [Lia](https://dribbble.com/LiaLuong).

It took a lot of playing around to get all the components on screen to resize and play along nicely (and represent the Box2D world as closely as possible). End result is not too bad if I say so myself.
