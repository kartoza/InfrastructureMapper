---
marp: true
theme: infrastructure
class: _lead
header: 'Infrastructure Mapper'
footer: 'Kartoza (Pty) Ltd. 2025'
---

<!-- Title Slide -->

# 🌍 *Infrastructure Mapper - Culinary Facilities*  
## *Hefni R. R. A.*  
📅 *04/07/2025*

---

## 👩‍💻 About Me

- Intern at **Kartoza**
- Bachelor of Engineering, majored in Geodetic Engineering
- Currently exploring GIS with a growing interest in open-source GIS. Passionate about GIS and map styling.
- Tools used: QGIS, QFieldCloud, PostgreSQL, pgAdmin, VS Code, Marp, GitHub, etc.

---

## 🧱 The Model

- The project uses a custom PostgreSQL/PostGIS schema  
- Diagram below shows the culinary facilities ERD: 

<img src="../img/culinaryfacilities-erd.png" alt="ERD" width="80%">

---

## 📋 The Forms

QGIS smart forms created to collect and validate field data efficiently.
<img src="../img/culinaryfacilities-forms.png" alt="ERD" width="45%">


---
## 🏞️ Field Collection

> Data collected in the field using mobile GIS apps and GPS-enabled devices.

![Field Photos](../img/culinaryfacilities-field.png)

---

## 🗺️ Collection Results

- **Total features collected:** 
    - `Points`: 80
- **Main types:** culinary spots.  
- **Area covered:** 15 km²  

<img src="../img/culinaryfacilities-collection.png" alt="ERD" width="40%">

---

## ❓ Analysis Problem

- How can we determine culinary facilities that are reachable within a specific travel time from a central point?
- Which culinary facilities that can be reached within 8 minutes and offer the best combination of **low price**, **high ratings**, specific **facilities** like Wi-Fi and indoor seating, and specific **category** like Cafe/Bakery? 

---

## ⚙️ Methodology

- A custom QGIS Model Designer diagram used for repeatable spatial processing.

![QGIS Model](../img/culinaryfacilities-model.png)

---

## 📊 Results

- Isochrones analysis output 
- Features within specific travel time and given parameters.
<img src="../img/culinaryfacilities-results.png" alt="ERD" width="57%">

---

## 💡 Insights

- Average Price Range by Category
- Rating Distribution
- Top Categories with High Ratings
- Most common facility
- Most common category
- Facilities Coverage
- Facilities by Category

---

## 🔬 Further Research

If I had more time, I would:

- Develop a specific travel mode for motorcycles to better represent real conditions, possibly using custom routing technology.
- Improve the model so users can select facilities and categories using dropdowns connected to the lookup table, ensuring updates are reflected automatically.
- Increase the study area and collect more data to improve the analysis

---

## 🧳 My Internship Experience

### Highlights:

- ✅ Mastered QGIS and explored various GIS tools and workflows  
- 🔍 Contributed to impactful projects
- 🌟 Improved problem-solving, adaptability, and critical thinking  
- ⏰ Enhanced time management while balancing multiple tasks and responsibilities 
- 🌍 Improved English communication skills through professional and collaborative engagements
 
---

## 📧 Contact Me

👤 Hefni Rae R. A.   
📨 hefniraera17@gmail.com  
🔗 [linkedin.com/in/hefniraera](https://www.linkedin.com/in/hefniraera/)  
💼 [github.com/hefniraera](https://github.com/hefniraera)

---