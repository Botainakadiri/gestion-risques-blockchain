// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GestionnaireRisqueContrepartie {
    // Structure pour une contrepartie
    struct Contrepartie {
        address portefeuille;
        uint256 scoreCredit;
        uint256 limiteExposition;
        uint256 expositionCourante;
        bool estActif;
    }
    
    // Variables d'état
    mapping(address => Contrepartie) public contreparties;

    // Événements
    event ContrepartieAjoutee(address indexed contrepartie, uint256 limiteExposition);
    event ExpositionMiseAJour(address indexed contrepartie, uint256 nouvelleExposition);
    event LimiteDepassee(address indexed contrepartie, uint256 exposition);
    event ContrepartieDesactivee(address indexed contrepartie);
    event ContrepartieReactivee(address indexed contrepartie);

    // Ajouter une contrepartie
    function ajouterContrepartie(address _portefeuille, uint256 _scoreCredit, uint256 _limiteExposition) public {
        require(_portefeuille != address(0), "Adresse invalide.");
        require(contreparties[_portefeuille].portefeuille == address(0), "Contrepartie existe deja.");
        require(_scoreCredit > 0, "Score de credit doit etre positif.");
        require(_limiteExposition > 0, "Limite d'exposition doit etre positive.");
        
        contreparties[_portefeuille] = Contrepartie({
            portefeuille: _portefeuille,
            scoreCredit: _scoreCredit,
            limiteExposition: _limiteExposition,
            expositionCourante: 0,
            estActif: true
        });
        emit ContrepartieAjoutee(_portefeuille, _limiteExposition);
    }

    // Mettre à jour l'exposition
    function mettreAJourExposition(address _contrepartie, uint256 _montant) public {
        require(_montant > 0, "Le montant doit etre positif.");
        Contrepartie storage c = contreparties[_contrepartie];
        require(c.portefeuille != address(0), "Contrepartie non existante.");
        require(c.estActif, "Contrepartie inactive.");
        
        c.expositionCourante += _montant;
        if (c.expositionCourante > c.limiteExposition) {
            emit LimiteDepassee(_contrepartie, c.expositionCourante);
        }
        emit ExpositionMiseAJour(_contrepartie, c.expositionCourante);
    }

    // Calculer le risque
    function calculerRisque(address _contrepartie) public view returns (uint256) {
        Contrepartie memory c = contreparties[_contrepartie];
        require(c.portefeuille != address(0), "Contrepartie non existante.");
        require(c.estActif, "Contrepartie inactive.");
        require(c.limiteExposition > 0, "Limite d'exposition non definie.");
        
        return (c.expositionCourante * 100) / c.limiteExposition / c.scoreCredit;
    }

    // Désactiver une contrepartie
    function desactiverContrepartie(address _contrepartie) public {
        Contrepartie storage c = contreparties[_contrepartie];
        require(c.portefeuille != address(0), "Contrepartie non existante.");
        require(c.estActif, "Deja inactive.");
        
        c.estActif = false;
        emit ContrepartieDesactivee(_contrepartie);
    }

    // Réactiver une contrepartie
    function reactiverContrepartie(address _contrepartie) public {
        Contrepartie storage c = contreparties[_contrepartie];
        require(c.portefeuille != address(0), "Contrepartie non existante.");
        require(!c.estActif, "Deja active.");
        
        c.estActif = true;
        emit ContrepartieReactivee(_contrepartie);
    }

    // Réinitialiser l'exposition d'une contrepartie
    function reinitialiserExposition(address _contrepartie) public {
        Contrepartie storage c = contreparties[_contrepartie];
        require(c.portefeuille != address(0), "Contrepartie non existante.");
        require(c.estActif, "Contrepartie inactive.");
        
        c.expositionCourante = 0;
        emit ExpositionMiseAJour(_contrepartie, c.expositionCourante);
    }
}
