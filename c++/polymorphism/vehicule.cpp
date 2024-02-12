#include <iostream>
#include <vector>
#include <memory>

using namespace std;

class Vehicule {
    protected:
        string marque;
        unsigned int date;
        double prix;
    public:
        Vehicule(string marque, unsigned int date, double prix)
        : marque(marque), date(date), prix(prix) {}
        virtual void affiche()  {cout<<"Vehicule:"<<endl;}
        // le destructeur est virtual pour pouvoir appeler les destructeurs des sous-classes
        // sinon ce sera ce destructeur qui sera appellé
        virtual ~Vehicule() {};
    };

class Voiture : public Vehicule {
    public:
        Voiture(string marque, unsigned int date, double prix)
        : Vehicule(marque, date, prix) {}
        ~Voiture() {cout<<"plus de bagnole"<<endl;}
        void affiche() {cout<<"Voiture:"<<marque<<endl;}
    };


class Avion : public Vehicule {
    public:
        Avion(string marque, unsigned int date, double prix)
        : Vehicule(marque, date, prix) {}
        ~Avion() {cout<<"plus d'avion"<<endl;}
        void affiche() {cout<<"Avion:"<<marque<<endl;}
    };

class Aeroport {
    protected:
        vector<unique_ptr<Vehicule>> vehicules;
        //vector<Vehicule*> vehicules; // si pointeurs C
    public:

        void affiche_vehicules() const {
            // const& obligatoire avec les smart pointers
            for (auto const& v:vehicules) {v->affiche();}
            }
        void ajouter_vehicules(Vehicule* v) {
            if (v != nullptr) {
                //vehicules.push_back(v); // si pointeurs C
                vehicules.push_back(unique_ptr<Vehicule>(v));
                }
            }
        void vider_vehicules() {
            // pas besoin de delete avec les smart pointers,
            // le destructeur correspondant sera appelé automatiquement
            //for(auto v: vehicules) {delete v;} // si pointeurs C
            vehicules.clear();
            }


    };
int main()
{
    Aeroport gva;
    gva.ajouter_vehicules(new Voiture("Peugeot", 1998, 147325.79));
    gva.ajouter_vehicules(new Voiture("Ford", 1998, 147325.79));
    gva.ajouter_vehicules(new Avion("Cessna", 1998, 147325.79));
    gva.affiche_vehicules();
    gva.vider_vehicules();
    cout<<"plus rien"<<endl;
    gva.affiche_vehicules();

    return 0;
}
