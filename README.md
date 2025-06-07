# Exemplo MikroTik para Vivo Fibra

Este repositório contém scripts para configurar roteadores MikroTik para uso com o serviço de internet Vivo Fibra. Os scripts foram testados no RB750GR3 e foram projetados para serem compatíveis com outros modelos de roteadores MikroTik.

Scripts Disponíveis

## vivofibra.rsc

Este script fornece uma configuração completa para configurar seu roteador MikroTik para uso imediato com o Vivo Fibra.

Recomendação: É altamente recomendável realizar uma redefinição de fábrica do seu roteador MikroTik antes de carregar este script. Isso garante uma configuração limpa e evita potenciais conflitos com as configurações existentes.

Para utilizar no seu roteador, faça o upload deste script dele e no terminal execute este comando:

```
/system/reset-configuration keep-users=yes run-after-reset=vivofibra.rsc no-defaults=yes
```

## fix_vivofibra.rsc

Este script foi desenvolvido para roteadores MikroTik já configurados, especialmente aqueles com configurações de login PPPoE da Vivo Fibra. Seu objetivo principal é resolver problemas comuns de navegação relacionados ao IPv6 na rede Vivo Fibra.

Para utilizar no seu roteador, faça o upload deste script dele e no terminal execute este comando:

```
fix_vivofibra.rsc
```