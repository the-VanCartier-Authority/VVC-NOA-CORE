import os
from model_router import ModelRouter

def test():
    # Ingrese su NVIDIA_API_KEY para probar local o en entorno de ejecución
    api_key = os.getenv("NVIDIA_API_KEY", "TU_NVIDIA_API_KEY_AQUI")
    
    router = ModelRouter()
    print(f"🚀 Probando motor: {router.active_model}")
    
    messages = [
        {"role": "system", "content": "Eres el motor de código de VVC-NOA."},
        {"role": "user", "content": "Escribe una función en Python de búsqueda binaria."}
    ]
    
    try:
        response = router.generate_response(api_key, messages)
        print("--- RESPUESTA DE GLM-5.3 ---")
        for chunk in response:
            print(chunk, end="", flush=True)
    except Exception as e:
        print(f"\n❌ Para ejecutar la prueba ingresa tu API Key. Detalles: {e}")

if __name__ == "__main__":
    test()
  
