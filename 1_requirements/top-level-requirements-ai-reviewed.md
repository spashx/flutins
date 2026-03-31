# Functional and Non-Functional Requirements
## Asset Inventory Application for Insurance Justification

> **Version:** 1.1
> **Date:** 2026-03-23
> **Status:** AI-reviewed -- Stakeholder validated -- Implementation in progress

---

# 1 CONTEXT AND OBJECTIVES

The application allows the user to justify the condition of their possessions to insurance providers by maintaining a multimedia catalogue of items, including photos, documents, and descriptive properties.

---

# 2 FUNCTIONAL REQUIREMENTS

## 2.1 Item Properties

### RQ-OBJ-001
The system shall represent each item as a collection of properties containing at minimum:
- Name (mandatory)
- Nature / category (mandatory)
- Acquisition date (mandatory)
- Serial number (optional)
- Main photo (mandatory)
- Additional photos (optional)
- Documents (optional), including the purchase invoice

### RQ-OBJ-002
The system shall allow the user to associate any number of tags (reusable across items) with an item.

### RQ-OBJ-003
The system shall allow the user to associate any number of custom properties (key/value pairs) with an item. Custom property keys are specific to each item and are NOT shared across items.

### RQ-OBJ-004
While an item is being created or edited, the system shall prevent the deletion of mandatory properties from the property collection.

---

## 2.2 Main Screen

### RQ-SCR-001
The system shall display all items on the main screen as a list showing a photo thumbnail and the item name.

### RQ-SCR-002
The system shall allow the user to sort the item list by any item property, in ascending or descending order.

### RQ-SCR-003
The system shall sort the item list by item name in ascending alphabetical order by default.

### RQ-SCR-004
The system shall display a text search bar on the main screen allowing the user to filter items by searching across all item properties or tags

---

## 2.3 Item Creation

### RQ-OBJ-005
The system shall allow the user to create a new item and enter its properties.

### RQ-OBJ-006
When the user attempts to save a new item, the system shall require all mandatory properties to be filled in before persisting the item.

### RQ-OBJ-007
When a new item is saved, the system shall insert it into the item list at the position determined by the current sort order.

### RQ-OBJ-008
When creating or editing an item, the system shall allow the user to associate a tag by selecting an existing tag or by creating a new one.

---

## 2.4 Item Editing

### RQ-OBJ-009
When the user taps an item in the list, the system shall display an edit screen allowing the user to modify all item properties.

### RQ-MED-001
When the user adds a photo to an item, the system shall offer the choice of:
- taking a photo with the device camera, or
- selecting an image from the device file system (defaulting to the OS-defined user image directory).

### RQ-MED-002
While the device has no camera detected, the system shall hide the "take a photo" option.

### RQ-MED-003
When the user adds a document to an item, the system shall allow the user to select a file from the device file system (defaulting to the OS-defined user documents directory). No camera option shall be presented for documents.

### RQ-MED-004
When the user activates edit mode on the media gallery of an item, the system shall display a checkbox on each photo and document thumbnail, allowing the user to select media for deletion.

---

## 2.5 Item Deletion

### RQ-OBJ-010
The system shall allow the user to delete one or more selected items.

### RQ-OBJ-011
When the user requests deletion of selected items, the system shall display a confirmation dialog stating the count of items to be deleted before executing the deletion.

---

## 2.6 Multi-Selection

### RQ-SEL-001
When the user performs a long-press on an item, the system shall enter multi-selection mode and mark that item as selected.

### RQ-SEL-002
While in multi-selection mode, the system shall display a Cancel button in the action bar. When the user taps Cancel, the system shall exit multi-selection mode and clear all selections.

### RQ-SEL-003
The system shall provide a filter mechanism allowing the user to select all items matching specified criteria (e.g., all items sharing a given tag).

---

## 2.7 Tag Management

### RQ-TAG-001
The system shall provide a tag management screen listing all existing tags.

### RQ-TAG-002
The system shall support full CRUD operations on tags (create, read, update, delete).

### RQ-TAG-003
When the user requests modification or deletion of a tag, the system shall display the number of items that will be affected before applying the change.

### RQ-TAG-004
When the user confirms deletion of a tag, the system shall silently remove that tag from all items that reference it.

---

## 2.8 Export and Sharing

### RQ-EXP-001
The system shall allow the user to export a selection of items as a PDF report including item photos and all properties.

### RQ-EXP-002
The system shall allow the user to export a selection of items as a ZIP archive containing the PDF report and all associated media files. The application shall ask the user via the operating system file manager a location where to store the archive. If not possible, the archive shall be saved into the user's document folder or home folder depending on the capabiltities of the operating system.

### RQ-EXP-003
The system shall allow the user to share the generated PDF or ZIP using the native OS share mechanism (email, messaging applications, etc.).

---

# 3 NON-FUNCTIONAL REQUIREMENTS

## 3.1 Target Platforms

### RQ-NFR-001 
The system shall be implemented in Flutter, targeting Windows and Android as primary platforms.

## 3.2 Data Storage

### RQ-DAT-001
The system shall store all application data in a local SQLite3 database.

### RQ-DAT-002
The system shall encrypt the SQLite3 database by default.

## 3.3 Security and Authentication

### RQ-SEC-001
The system shall use a device-specific automatically generated encryption key, transparent to the user and managed by the OS keystore. No authentication screen shall be required at launch.

## 3.4 User Interface

### RQ-NFR-002
The system shall provide a professional-grade user interface using Material Design 3 with a cohesive color scheme, consistent typography, and thoughtful component styling across all screens. The UI shall support both light and dark modes, adapting automatically to the operating system preference.

---

# APPENDIX A -- AI REVIEW CHANGE LOG

| # | Type | Detail |
|---|---|---|
| 1 | Duplicate removed | `purchase invoice` was listed both as a standalone property and inside `documents`. Retained only under documents. |
| 2 | Numbering fixed | Section 3: `1)` / `2)` corrected to `3.1` / `3.2` |
| 3 | Typos corrected | `princpale`, `parmis`, `propriétées` corrected |
| 4 | Added | RQ-SCR-003: default sort = ascending alphabetical by name |
| 5 | Added | RQ-SCR-004: text search bar on main screen |
| 6 | Added | RQ-SEL-002: exit multi-selection via Cancel button |
| 7 | Added | RQ-MED-002: hide camera option when no camera detected (Windows) |
| 8 | Added | RQ-MED-004: media deletion via edit mode with checkboxes |
| 9 | Clarified | RQ-OBJ-003: custom properties are per-item -- keys NOT shared across items |
| 10 | Added | RQ-TAG-004: tag deletion cascades silently after confirmation |
| 11 | New section | Section 2.8: PDF export, ZIP export, and native OS sharing (RQ-EXP-001/002/003) |
| 12 | Resolved | RQ-SEC-001: transparent OS-keystore encryption selected (Option B). No authentication screen at launch. |


