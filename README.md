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
