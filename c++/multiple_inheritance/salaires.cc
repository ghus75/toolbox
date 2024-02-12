#include <iostream>
#include <vector>
#include <memory>
using namespace std;

/*
Employe                       EmployeARisque
   └─ Commercial                     |
   |     └─ Vendeur                  |
   |     └─ Representant             |
   └─ Technicien                     |
   |     └─ TechnARisque ────────────┘
   └─ Manutentionnaire               |
         └─ ManutARisque ────────────┘

*/

class Employe {
    protected:
        string nom;
        string prenom;
        unsigned int age;
        string date;
    public:
        Employe(string nom="Jean-Claude", string prenom="Dus", unsigned int age=20, string date="1980")
        : nom(nom), prenom(prenom), age(age), date(date) {}
        virtual ~Employe() {};

        virtual double calculer_salaire() const = 0; // rend la classe abstraite
        string get_nom() const { return "L'employé " + nom + " " + prenom;}
    };

class EmployeARisque {
    protected:
        unsigned int prime;
    public:
        EmployeARisque(unsigned int prime=100): prime(prime) {}
        virtual ~EmployeARisque() {}
    };

class Commercial : public Employe {
    private: double chiffre_affaire;
    public:
        Commercial(string nom, string prenom, unsigned int age, string date, double chiffre_affaire=0.0)
        : Employe(nom, prenom, age, date), chiffre_affaire(chiffre_affaire) {}
        ~Commercial() {}

    };

class Vendeur : public Commercial {
    private: double chiffre_affaire;
    public:
        Vendeur(string nom, string prenom, unsigned int age, string date, double chiffre_affaire=0.0)
        : Commercial(nom, prenom, age, date, chiffre_affaire) {}
        ~Vendeur() {}
        double calculer_salaire() const {return 0.2*chiffre_affaire + 400;}
        string get_nom() const { return "Le vendeur " + nom + " " + prenom;}
        };

class Representant : public Commercial {
    private: double chiffre_affaire;
    public:
        Representant(string nom, string prenom, unsigned int age, string date, double chiffre_affaire=0.0)
        : Commercial(nom, prenom, age, date, chiffre_affaire) {}
        ~Representant() {}
        double calculer_salaire() const {return 0.2*chiffre_affaire + 800;}
        string get_nom() const { return "Le representant " + nom + " " + prenom;}
        };

class Technicien : public Employe {
    protected: unsigned int nb_units;
    public:
        Technicien(string nom, string prenom, unsigned int age, string date, unsigned int nb_units=0)
        : Employe(nom, prenom, age, date), nb_units(nb_units) {}
        ~Technicien() {}
        double calculer_salaire() const {return 5*nb_units;}
        string get_nom() const { return "Le Technicien " + nom + " " + prenom;}
        };

class Manutentionnaire : public Employe {
    protected: unsigned int nb_heures;
    public:
        Manutentionnaire(string nom, string prenom, unsigned int age, string date, unsigned int nb_heures=0)
        : Employe(nom, prenom, age, date), nb_heures(nb_heures) {}
        ~Manutentionnaire() {}
        double calculer_salaire() const {return 65*nb_heures;}
        string get_nom() const { return "Le Technicien " + nom + " " + prenom;}
        };

class TechnARisque : public Technicien, public EmployeARisque {
    private:
        unsigned int prime;
    public:
        TechnARisque(string nom, string prenom, unsigned int age, string date,
        unsigned int nb_units, unsigned int prime)
        : Technicien(nom, prenom, age, date, nb_units), prime(prime){}
        ~TechnARisque() {}
        double calculer_salaire() const {return 5*nb_units + prime;}
    };

class ManutARisque : public Manutentionnaire, public EmployeARisque {
    private:
        unsigned int prime;
    public:
        ManutARisque(string nom, string prenom, unsigned int age, string date,
        unsigned int nb_heures, unsigned int prime)
        : Manutentionnaire(nom, prenom, age, date, nb_heures), prime(prime){}
        ~ManutARisque() {}
        double calculer_salaire() const {return 65*nb_heures + prime;}
    };

class Personnel {
    private:
        vector<unique_ptr<Employe>> Employes;
    public:
        void ajouter_employe(Employe* emp) {
            if (emp != nullptr) { Employes.push_back(unique_ptr<Employe>(emp)); }
            }
        void afficher_salaires() const {
            for(auto const& emp: Employes) {
                cout<<emp->get_nom()<<" gagne "<<emp->calculer_salaire()<<" francs"<<endl;
                }
            }
        double salaire_moyen() const {
            double moy = 0;
            for(auto const& emp: Employes) { moy += emp->calculer_salaire(); }
            return moy/= (Employes.size());
            }
        void licencie() { Employes.clear(); }
    };


int main () {

    Personnel p;
    p.ajouter_employe(new Vendeur("Pierre", "Business", 45, "1995", 30000));
    p.ajouter_employe(new Representant("Léon", "Vendtout", 25, "2001", 20000));
    p.ajouter_employe(new Technicien("Yves", "Bosseur", 28, "1998", 1000));
    p.ajouter_employe(new Manutentionnaire("Jeanne", "Stocketout", 32, "1998", 45));
    p.ajouter_employe(new TechnARisque("Jean", "Flippe", 28, "2000", 1000, 200));
    p.ajouter_employe(new ManutARisque("Al", "Abordage", 30, "2001", 45, 120));

    p.afficher_salaires();
    cout << "Le salaire moyen dans l'entreprise est de "
    << p.salaire_moyen() << " francs." << endl;
    // libération mémoire
    p.licencie();

}
