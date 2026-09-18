# Regras globais de gameplay

`default_rules.tres` é compartilhado pelas três fases. Altere esse único recurso quando a mudança deve valer para todas as músicas.

Ele concentra:

- tempo de viagem e janelas de julgamento;
- tolerância para entradas antecipadas;
- pontos, pesos de precisão e multiplicador de combo;
- limites das classificações de `S` a `D`;
- cores, largura e contraste visual das trilhas.

Dados específicos de uma música continuam em `songData/*.tres`. As posições de surgimento e acerto ficam nos marcadores `NoteSpawn` e `HitTarget` de cada cena.
