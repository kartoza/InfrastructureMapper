# 🌐 Infrastructure Mapper

Welcome to **Infrastructure Mapper**! This repository contains guidelines and conventions for a spatial database intended to be used managing infrastructure-related data.

It is primarily a SQL Schema for PostgreSQL, a set of fixtures to load that schema with default values (particularly for lookup tables) and a set of QGIS forms and layer styles for visualising the data.

---

## 📖 Table of Contents

- [🌐 Infrastructure Mapper](#-infrastructure-mapper)
  - [📖 Table of Contents](#-table-of-contents)
  - [🚀 Project Overview](#-project-overview)
  - [📋 Naming Conventions](#-naming-conventions)
    - [🗄️ SQL Standards](#️-sql-standards)
    - [🏷️ Entity Names](#️-entity-names)
    - [📊 Lookup Tables](#-lookup-tables)
  - [🗺️ ERD Conventions](#️-erd-conventions)
    - [🎨 Attribute Colors](#-attribute-colors)
    - [🏗️ Table Structure](#️-table-structure)
  - [📂 Folder Structure](#-folder-structure)
  - [📜 License](#-license)
  - [✨ Contributing](#-contributing)
  - [📧 Contact](#-contact)

---

## 🚀 Project Overview

Infrastructure Mapper is a set of conventions and best practices for managing infrastructure data. It ensures consistency, readability, and maintainability across projects. Whether you're working with SQL databases or designing ERDs, this guide has you covered! 🎉

---

## 📋 Naming Conventions

### 🗄️ SQL Standards

- **Keywords and statements** must be written in **UPPER CASE**.  
  Example:  

  ```sql
  SELECT * FROM electricity_line;
  ```

### 🏷️ Entity Names

- Use **singular** names.  
  Example:  
  ```electricity_line_type``` not ```electricity_line_types```
- Use **lowercase** with **underscores (_)** to separate words.  
  Example:  
  ```water_point``` not ```WaterPoint```

### 📊 Lookup Tables

- Names must be in **lowercase**.  
  Example:  
  ```electricity_line_condition``` not ```ElectricityLineCondition```

---

## 🗺️ ERD Conventions

### 🎨 Attribute Colors

- **Grey**: `uuid`, `last_update`, `last_update_by`  
- **Black**: `geometry` fields (positioned above grey attributes)  
- **Green**: Foreign key fields (always positioned last)  
- **Blue**: Constraints, associated fields, and association (junction) tables  

### 🏗️ Table Structure

1. Start with `name(s)`, `type`, `notes` (in that order).  
2. Explicitly include units for length and depth fields (default: meters).  
   Example:  
   ```crown_radius_m``` not ```crown_radius```
3. Use **amperes** for current and **volts** for voltage.  
4. For the `image` field, insert the file path as text.

---

## 📂 Folder Structure

```plaintext
InfrastructureMapper/
├── data/               # Raw and processed data files
├── docs/               # Documentation and ERD diagrams
├── src/                # Source code for the project
├── tests/              # Unit tests and test cases
└── README.md           # Project overview and conventions
```

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## ✨ Contributing

We welcome contributions! Please read the [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to get started.

---

## 📧 Contact

Have questions or feedback? Feel free to reach out!  
📧 Email: [info@kartoza.com](mailto:info@kartoza.com)  
🌐 Website: [kartoza.com](https://kartoza.com)

---

Made with ❤️ by Tim Sutton (@timlinux) and Kartoza Interns.
