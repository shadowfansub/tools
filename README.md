# Shadow Fansub — Ferramentas

Repositório destinado à organização das ferramentas usadas pela **Shadow Fansub**.  

## `number-word-detector.py`

Aplicativo que detecta palavras-numéricas escritas em textos (ex.: "three", "cem", "mil") e as destaca no texto. Suporta múltiplos idiomas (ex.: English, Portuguese) utilizando a biblioteca `num2words` para gerar um dicionário de palavras-numéricas.

Principais características:
- Interface gráfica com área de entrada e saída, realce de termos e lista dos números encontrados.
- Suporte a pelo menos `en` e `pt_BR` (selecionável no combo de idiomas).
- Gera um dicionário de palavras-numéricas com `num2words` (configurável até 1000 por padrão).

Dependências e execução:
- Instale dependências: `pip install num2words`
- Execute: `python number-word-detector.py`

## `fuzzy-text-checker.py`

Aplicativo que detecta possíveis erros/typos em um documento comparando palavras contra um dicionário de termos conhecido usando correspondência aproximada (fuzzy matching). Utiliza a biblioteca `rapidfuzz` para calcular similaridade entre strings.

Principais características:
- Dois painéis para carregar/editar: (1) lista de termos (dicionário) e (2) documento a ser verificado.
- Ajuste de limiar de similaridade (porcentagem) para controlar sensibilidade.
- Exibe ocorrências suspeitas com contexto, permite marcar itens como resolvidos.

Dependências e execução:
- Instale dependências: `pip install rapidfuzz`
- Execute: `python fuzzy-text-checker.py`
