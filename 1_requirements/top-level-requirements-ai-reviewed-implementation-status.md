
# APPENDIX B -- Implementation Status

| Requirement ID | Description | Status | ADR | Date |
|---|---|---|---|---|
| RQ-NFR-001 | Flutter app targeting Windows and Android | Implemented and tested | ADR-002 | 2026-03-25 |
| RQ-DAT-001 | Local SQLite3 database via Drift ORM | Implemented and tested | ADR-003 | 2026-03-25 |
| RQ-DAT-002 | SQLite3 database encrypted by default (SQLCipher) | Implemented and tested | ADR-003 | 2026-03-25 |
| RQ-SEC-001 | Device-specific OS-keystore encryption key, transparent to user | Implemented and tested | ADR-003 | 2026-03-25 |
| RQ-OBJ-001 | Item entity with mandatory/optional properties | Implemented and tested (data layer) | ADR-004 | 2026-03-25 |
| RQ-OBJ-002 | Item-tag association | Implemented and tested (data layer) | ADR-004 | 2026-03-25 |
| RQ-OBJ-003 | Per-item custom key/value properties | Implemented and tested (data layer) | ADR-004 | 2026-03-25 |
| RQ-OBJ-004 | Prevent deletion of mandatory properties during edit | Implemented and tested (ItemValidator) | ADR-004 | 2026-03-25 |
| RQ-OBJ-005 | Create new item | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-OBJ-006 | Require mandatory properties before save | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-OBJ-007 | Insert item at sort-order position after save | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-OBJ-008 | Associate tag when creating/editing item | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-OBJ-009 | Edit screen on item tap | Implemented and tested | ADR-006 | 2026-03-26 |
| RQ-OBJ-010 | Delete one or more selected items | Implemented and tested | ADR-004, ADR-007 | 2026-03-29 |
| RQ-OBJ-011 | Deletion confirmation dialog with count | Implemented and tested | ADR-007 | 2026-03-29 |
| RQ-SCR-001 | Main screen item list with thumbnail and name | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-SCR-002 | Sort item list by any property | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-SCR-003 | Default sort: ascending alphabetical by name | Implemented and tested | ADR-005 | 2026-03-26 |
| RQ-SCR-004 | Text search bar filtering across all properties | Implemented and tested | ADR-008 | 2026-03-29 |
| RQ-SEL-001 | Enter multi-selection mode on long-press | Implemented and tested | ADR-007 | 2026-03-29 |
| RQ-SEL-002 | Cancel button exits multi-selection mode | Implemented and tested | ADR-007 | 2026-03-29 |
| RQ-SEL-003 | Filter mechanism to select all items by criteria | Implemented and tested | ADR-007 | 2026-03-29 |
| RQ-MED-001 | Add photo via camera or file system | Implemented and tested | ADR-009 | 2026-03-29 |
| RQ-MED-002 | Hide camera option when no camera detected | Implemented and tested | ADR-009 | 2026-03-29 |
| RQ-MED-003 | Add document via file system only | Implemented and tested | ADR-009 | 2026-03-29 |
| RQ-MED-004 | Media gallery edit mode with checkboxes for deletion | Implemented and tested | ADR-009 | 2026-03-29 |
| RQ-TAG-001 | Tag management screen | Implemented and tested | ADR-010 | 2026-03-30 |
| RQ-TAG-002 | Full CRUD on tags | Implemented and tested | ADR-004, ADR-010 | 2026-03-30 |
| RQ-TAG-003 | Show affected item count before tag modification/deletion | Implemented and tested | ADR-004, ADR-010 | 2026-03-30 |
| RQ-TAG-004 | Tag deletion cascades silently to all referencing items | Implemented (FK ON DELETE CASCADE) | ADR-003 | 2026-03-25 |
| RQ-EXP-001 | Export selection as PDF report | Implemented and tested | ADR-011 | 2026-03-30 |
| RQ-EXP-002 | Export selection as ZIP archive (PDF + media) with native file save dialog and fallback | Implemented and tested | ADR-011, ADR-012 | 2026-03-31 |
| RQ-EXP-003 | Share PDF or ZIP via native OS share mechanism | Implemented and tested | ADR-011 | 2026-03-31 |
| RQ-NFR-002 | Professional-grade Material 3 UI with light/dark mode | Implemented and tested | ADR-013 | 2026-03-31 |
| RQ-ABT-001 | About dialog with app name, version, author, licence, and AI-generation attribution | Implemented and tested | ADR-014 | 2026-03-31 |

---

# APPENDIX C -- Issues

| Issue ID | Related Req | Summary | Root Cause | Fix | Date |
|---|---|---|---|---|---|
| ISS-001 | RQ-MED-001 | Main photo disappears after save and re-edit | `ItemRepositoryImpl.saveItem()` persisted item row, custom properties, and tag associations but never called `mediaDao` to persist media attachments. The load path read media correctly, but nothing was ever written. | Added `replaceAttachmentsForItem()` to `MediaDao` (delete-all + re-insert). Called it inside `saveItem()` transaction alongside properties and tags. Added 3 regression tests. | 2026-03-30 |

