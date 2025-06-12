# ✨ Contributing to Infrastructure Mapper

Thank you for considering contributing to **Infrastructure Mapper**! We welcome contributions of all kinds, including bug fixes, feature requests, documentation improvements, and more. Please follow the guidelines below to ensure a smooth contribution process.

---

## 🛠️ How to Contribute

### 1. Fork the Repository

- Click the **Fork** button at the top-right corner of this repository to create your own copy.

### 2. Clone Your Fork

- Clone your forked repository to your local machine:

  ```bash
  git clone https://github.com/timlinux/InfrastructureMapper.git
  cd InfrastructureMapper
  ```

### 3. Create a Branch

- Create a new branch for your changes:

  ```bash
  git checkout -b feature/your-feature-name
  ```

### 4. Make Your Changes

- Implement your changes in the appropriate files.
- Follow the coding conventions and guidelines outlined in the project.

### 5. Test Your Changes

- Run the tests to ensure your changes don't break anything:

  ```bash
  pytest
  ```

### 6. Commit Your Changes

- Write clear and concise commit messages:

  ```bash
  git add .
  git commit -m "Add a brief description of your changes"
  ```

### 7. Push Your Changes

- Push your branch to your forked repository:

  ```bash
  git push origin feature/your-feature-name
  ```

### 8. Submit a Pull Request

- Go to the original repository and click **New Pull Request**.
- Provide a detailed description of your changes and link any related issues.

---

## 🧹 Code of Conduct

Please adhere to our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming and inclusive environment for everyone.

---

## 📝 Guidelines

### Coding Standards

- Follow the naming conventions and SQL standards outlined in the [README.md](README.md).
- Write clean, readable, and well-documented code.

### Commit Messages

- Use the following format for commit messages:

  ```
  [Type] Short description of the change
  ```

  Examples of types: `Fix`, `Add`, `Update`, `Remove`.

### Testing

- Ensure all tests pass before submitting your pull request.
- Add new tests for any new features or bug fixes.

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

---

## 💡 Need Help?

If you have any questions or need assistance, feel free to reach out via [info@kartoza.com](mailto:info@kartoza.com).

---

Thank you for contributing! 🚀
