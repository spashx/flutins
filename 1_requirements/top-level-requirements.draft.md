
# 1 CONTEXTE ET OBJECTIFS

On désire réaliser une application permettant de justifier auprès notamment des assurances, l'état de certains biens possédés par l'utilisateur. 


# 2 REQUIREMENTS FONCTIONNELS

2.1) propriétés des objets

L'application représente un catalogue d'objets, avec un certain nombre de propriétés et de documents.
Notamment:
- le nom de l'objet - obligatoire
- sa nature - obligatoire
- la date d'acquisition - obligatoire
- la facture d'achat
- le numéro de série
- diverses photos, dont une photo principale - obligatoire
- divers documents, dont la facture d'achat

On doit pouvoir associer aux objets des tags (réutilisables entre objets) et une collection de propriétés personnalisées (sous forme de paires (clé, valeur)). les propriétés enumérées ci-dessus sont des entrées prédéfinies dans la collection des propriétés. les propriétés obligatoires ne peuvent pas être supprimées de la collection.


2.2) Écran principal

L'écran principal doit afficher les objets (photo, noms) dans une liste pouvant être triée par n'importe quelle propriété de l'objet.

2.3) Création d'un nouvel objet

L'utilisateur doit pouvoir créer un nouvel objet et saisir ses propriétés. la saisie des propriétés obligatoires est nécessaire pour pouvoir sauvegarder l'objet  nouvellement créé. Lorsque l'objet est créé il s'affiche dans la liste dans l'ordre de tri défini.
Il doit également avoir la possibilité d'ajouter un tag, soit existant soit à créer nouvellement.

2.4) Modification d'un objet
lorsque l'utilisateur clique sur un objet, un écran s'affiche permettant de modifier ses propriétés. 
- pour ajouter une photo, l'application doit proposer à l'utilisateur soit de prendre une photo avec l'appareil, soit de choisir une image parmi les fichiers de l'appareil en sélectionnant par défaut le répertoire de l'utilisateur contenant les images tel que défini par le système d'exploitation.
- pour ajouter un document, le processus est identique aux photos mais sans proposer de prendre une photo.


2.5) suppression d'un ou plusieurs objets
L'utilisateur peut supprimer un ou plusieurs objets sélectionnés. L'application doit demander confirmation avant d'effectuer la suppression.


2.6) Selection d'un ou plusieurs objets
L'utilisateur doit pouvoir sélectioner un ou plusieurs éléments avec un appui long sur un objet. il doit disposer également d'un moyen pour sélectionner plusieurs objet au traver d'un filtrer sur les propriétés (par exemple sélectionner tous les objects ayant le tag "cuisine")


2.7) Édition des tags
L'utilisateur doit avoir la possibilité de lister tous les tags et d'effectuer les actions CRUD dessus. pour les opérations de modification/suppression, l'informer du nombre d'objets impactés avant d'appliquer.




# 3 REQUIREMENTS NON-FONCTIONNELS

1) l'application doit être implémentée en flutter, en visant en priorité les plateformes windows et android
2) les données seront stockées dans une base sqlite3. La base de donnée doit être cryptée par défaut.






