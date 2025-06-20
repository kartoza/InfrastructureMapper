# 🌐 Infrastructure Mapper

Welcome to **Infrastructure Mapper**! This repository contains guidelines and conventions for a spatial database intended to be used managing infrastructure-related data.

---

## 📖 Table of Contents

- [🌐 Infrastructure Mapper](#-infrastructure-mapper)
  - [📖 Table of Contents](#-table-of-contents)
  - [🚀 Project Overview](#-project-overview)
  - [📂 Folder Structure](#-folder-structure)
  - [📜 License](#-license)
  - [⚒️ Using](#️-using)
  - [🧊 Using the Nix Flake](#-using-the-nix-flake)
  - [✨ Contributing](#-contributing)
  - [📧 Contact](#-contact)
  - [Contributors](#contributors)

---

## 🚀 Project Overview

This project consists of:

1. a [SQL Schema](sql/schema.README.md) for PostgreSQL,
2. a set of fixtures to load that schema with default values (particularly for lookup tables)
3. a set of QGIS forms and layer styles for visualising the data

## 📂 Folder Structure

```plaintext
InfrastructureMapper/
├── qml/               # QGIS layer style and form definitions
├── diagrams/               # Documentation and ERD diagrams
├── sql/                # Chema and fixtures to load into postgres
├── tests/              # Unit tests and test cases
└── README.md           # Project overview and conventions
```

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## ⚒️ Using

Simply take the sql files in the sql folder and load them into postgres.

## 🧊 Using the Nix Flake

You can use the provided `flake.nix` to get a fully reproducible development environment and to run QGIS with the correct profile.

1. **Install [Nix](https://nixos.org/download.html)** (if you haven’t already).
2. **Enter the development shell:**

```bash
nix develop
```

This gives you all the tools and dependencies you need for working on this project.

1. **Run QGIS with the project profile:**

```bash
  nix run .#qgis
```

Or, for the long-term release version:

```bash
nix run .#qgis-ltr
```

1. **VSCode users:**  

You can launch a ready-to-use VSCode environment:

```bash
./vscode.sh
```

---

This makes it easy to get started and ensures everyone is using the same environment!

## ✨ Contributing

We welcome contributions! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to get started.

---

## 📧 Contact

Have questions or feedback? Feel free to reach out!  
📧 Email: [info@kartoza.com](mailto:info@kartoza.com)  
🌐 Website: [kartoza.com](https://kartoza.com)

## Contributors

- [Tim Sutton](https://github.com/timlinux) - project lead
-  

---

Made with ❤️ by Tim Sutton (@timlinux) and Kartoza Interns.
