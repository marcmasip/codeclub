# codeclub 🐧
A personal system experiment inspired by *Linux From Scratch* and minimalist systems such as *Tiny Core Linux*.

An attempt to build **just enough operating system*** to support modest desktop and server setups.

A system where every component is visible, sourced, and open to exploration.
Favoring **understanding over abstraction** and **intent over excess**. 🕊️

This repository acts as a **technical notebook** documenting the build structure, scripts, and experiments behind the system.


## ⚗ ️[Desktop](desktop/README.md)
The full-blown lab.

This repository contains the scripts used to compile the base system and progressively install software on top of it.
The framework is intentionally simple:
1. obtain the source
2. build it
3. install it into the system

***📰 News*** :  3rd iteration uses more verasatile install scripts capable of isolating the build and install process to review, tune and package results.
See [the cutest package manager](https://github.com/marcmasip/codeclub/blob/main/desktop/install.sh).

Projects live directly inside the system and evolve with it.
When a new idea appears the workflow is straightforward:
- unpack the source
- move it into the development stage
- modify
- compile
- install

The running system becomes the **living result of the experiments**.
If a modification proves valuable, patches can be generated from the source tree and reused by the installation scripts. (WIP)

This is not a universal solution.
It is a personal ecosystem.
A controlled, **peaceful anarchy** where experimentation is the rule and the system evolves with you.


## 🌐 [Server Edition !](server/README.md)
A minimal Linux host intended to run containers and services.

Same philosophy:
minimal base system, explicit components, reproducible builds.




# Motivation
The project started partly as a way to step away from the increasing monetization of software ecosystems and return to something simpler: software that just does its job.

Working with open projects like Redmine highlighted a useful contrast with comercial equivalents, systems built to work, not to extract value.

Building the system manually became a way to explore a recurring question that appears when dealing with large stacks of tools and dependencies:

> what are all these pieces actually solving?

In the end the idea is simple:
**code exists to solve problems and remain versatile.**



