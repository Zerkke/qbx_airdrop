# 📦 qbx_airdrop

Script de **Airdrop Tático em Tempo Real** para FiveM, desenvolvido para a framework **QBX / Qbox** com suporte para **ox_inventory** e **ox_target**.

---

## 🚀 Funcionalidades

* ✈️ **Voo de Alta Altitude Inteligente:** O avião voa a uma altitude mínima de 420m (evita edifícios e montanhas) com prevenção de colisão de IA nativa.
* 🪂 **Descida Realista:** Animação de descida da caixa ancorada a um paraquedas.
* 💨 **Fumo Sinalizador Tático:** Efeito de fumo vermelho (*flare*) visível a partir do momento em que a caixa sai do avião até tocar no chão.
* 🔭 **LOD Estendido (3000m):** Garante que os jogadores conseguem ver o avião, a caixa e o paraquedas no céu, mesmo a longas distâncias do chão.
* 📍 **Marcação no Mapa:** Cria automaticamente uma **Zona Vermelha (PvP)** com raio circular e ícone tático central.
* 🔊 **Sinalizador Sonoro D3:** Emite beeps sonoros táticos cujo volume aumenta dinamicamente à medida que o jogador se aproxima da caixa.
* 🔒 **Temporizador de Desbloqueio:** Exibe um marcador luminoso e texto 3D informando quanto tempo falta para abrir a caixa.
* 📦 **Integração ox_target & ox_inventory:** Interação rápida para abrir o *stash* do airdrop assim que estiver desbloqueado.

---

## 📋 Dependências

Garante que tens as seguintes *resources* instaladas e a correr no teu servidor:

* [qbx_core](https://github.com/Qbox-project/qbx_core)
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_target](https://github.com/overextended/ox_target)
* [ox_inventory](https://github.com/overextended/ox_inventory)

---

## 🛠️ Instalação

1. Faz o download ou coloca a pasta `qbx_airdrop` dentro do teu diretório `resources/`.
2. Adiciona a seguinte linha ao teu `server.cfg`:
   ```cfg
   ensure qbx_airdrop
