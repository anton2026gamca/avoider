# Avoider

A game where you are a space ship, you fly through the space, dodge meteoroids and shoot them. You can also control what you will invest your power into (e.g. acceleration, shields, etc.)

I built this project for [midnight](https://midnight.hackclub.com/), an event by [Hack Club](https://hackclub.com/).

This project is built using the [Godot Engine](https://godotengine.org/).

<img width="2729" height="1519" alt="2025-12-08_17-48-47" src="https://github.com/user-attachments/assets/837c3bf3-c12d-4499-9875-e9986890438c" />

## How to play

Visit [this link](https://anton2026gamca.github.io/avoider/)

## Controls
| Action       | Key(s)               |
|--------------|----------------------|
| Accelerate   | `W` or `Up Arrow`    |
| Decelerate   | `S` or `Down Arrow`  |
| Rotate Left  | `A` or `Left Arrow`  |
| Rotate Right | `D` or `Right Arrow` |
| Shoot        | `Space`              |

## Installation

These instructions explain how to open and run the project locally using Godot, and how to run the prebuilt Web export that is included in the `export/web` folder.

- To open the project in Godot:
  - Requirements:
    - Godot Engine 4.5
    - (Optional) Python 3 for testing the web build locally

  1. Start Godot
  2. Choose "Import" or "Open" and select this project's folder
  3. Once the project loads, press the Play button to run the project. If prompted to select a main scene, choose `src/world/main/main.tscn`

- Run the prebuilt Web export locally:
	1. The repository contains a prebuilt web export in `export/web`. To test it locally, run this in the repository root:

  ```bash
  cd export/web
  python3 -m http.server 8000
  ```

  2. Open your browser at http://localhost:8000/index.html

- To host your own version on github pages:
  1. Fork this repository.
  2. Go to `Settings` -> `Pages`.
  3. Under `Source`, select `Github Actions` and save.

  - It should now build and deploy automatically, there is a github actions workflow set up in `.github/workflows`. The game should be available at `https://<your-github-username>.github.io/avoider/`.
