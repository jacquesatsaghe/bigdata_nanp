from airflow.decorators import dag, task
from datetime import datetime

@dag(
    dag_id="Simple.test", # <--- Le nom qui apparaîtra dans l'interface
    schedule="* * * * *", # every 1 minutes
    #schedule=None, # Déclenchement manuel uniquement pour le test
    start_date=datetime(2024, 1, 1), # date et heure de declenchement
    catchup=False,
    tags=["test", "x-com"],
)
def simple_test_logic():
    
    @task()
    def extract():
        return "Données extraites avec Python 3.12"

    @task()
    def transform_a(data: str):
        return f"{data.upper()} (VIA A)"

    @task()
    def transform_b(data: str):
        return f"{data.capitalize()} (VIA B)"

    @task()
    def load(data_a: str, data_b: str):
        print(f"Chargement final : {data_a} ET {data_b}")

    # Définition du workflow parallèle
    raw_data = extract()
    
    # Ces deux tâches se lanceront en même temps
    res_a = transform_a(raw_data)
    res_b = transform_b(raw_data)
    
    # Load attend que les deux soient terminées
    load(res_a, res_b)

simple_test_logic()
