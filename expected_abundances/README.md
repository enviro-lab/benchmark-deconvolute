# Control mixture lineages contents explained

## Overview
Below, we have dictionaries mapping
* control names to their associated lineage
* original mixture names (from files) to the formal names used in the paper

We also include a list of
* samples that were dropped from the analysis.

## Mixture 2 lineage
This maps each mixture name to its general lineage and more specific pangolin lineage.

NOTE: We relabeled Twist:USA/CA9/2020 in Control 6 to Wuhan-hu-1:B to match the lineage that lineage detection software would assign.

```
control_map = {
    "Control 2":  "Wuhan-hu-1:B",
    "Control 23": "Delta:B.1.617.2",
    "Control 48": "Omicron:BA.1",
    "Control 19": "Iota:B.1.526",
    "Control 17": "Gamma:P.1",
    "Control 15": "Alpha:B.1.1.7",
    "Control 6":  "Wuhan-hu-1:B",
    "Control 50": "Omicron:BA.2",
    "Control 51": "Omicron:BA.2",
    "Control 62": "Omicron:BG",
    "Control 63": "Omicron:BG",
    "Control 64": "Omicron:BA.5",
    "Control 65": "Omicron:BA.5",
    "Control 66": "Omicron:BA.4",
    "Control 67": "Omicron:BA.4",
    "NFW": "NFW:NFW",
}
```

## Relabeled mixtures
This is how we relabeled the mixtures to have names resemlbing the mixture contents of each sample.

```
mixture_renames = {
    'Mixture01': '0ADGIO1O2O3O4O5',
    'Mixture02': '0ADGIO1',
    'Mixture03': 'O2O3O4O5',
    'Mixture04': '0AGIO1O2',
    'Mixture05': '0O5O3O4',
    'Mixture06': 'ADGIO1O2O3',
    'Mixture07': 'AGIO3O4O5',
    'Mixture08': 'O1O2O3O4O5',
    'Mixture09': '0',
    'Mixture10': 'O1O2',
    'Mixture11': 'O3',
    'Mixture12': 'O5',
    'Mixture13': 'O4',
    'Mixture14': '0-2',
    'Mixture15': 'A',
    'Mixture16': 'G',
    'Mixture17': 'I',
    'Mixture18': 'D',
    'Mixture19': 'O1',
    'Mixture20': 'O2',
    'Mixture21': '0-3',
    'Mixture22': 'O3-2',
    'Mixture23': 'O3-3',
    'Mixture24': 'O5-2',
    'Mixture25': 'O5-3',
    'Mixture26': 'O4-2',
    'Mixture27': 'O4-3',
    'Mixture28': 'O2-2',
    'Mixture29': 'O2O3O4O5-2',
    'Mixture30': 'O2O3O4O5-3',
    'Mixture31': '0ADGIO1-2',
    'Mixture32': '0AIO1O2O3O4O5',
    'Mixture33': '0-4',
    'Mixture34': 'A-2',
    'Mixture35': 'G-2',
    'Mixture36': 'I-2',
    'Mixture37': 'D-2',
    'Mixture38': 'O1-2',
    'Mixture39': 'O2-3',
    'Mixture40': 'O3-4',
    'Mixture41': 'O5-4',
    'Mixture42': 'O4-4'
}
mixture_renames = {m:n.lower() for m,n in mixture_renames.items()}
```

## These mixtures were dropped from analysis
They may have been mislabeled. Based on the lineages present in each pair, they seemed to have been swapped in the lab, containing their neighbor's mixture rather than their own. To be safe, we dropped them.

```
mixtures2drop = ["Mixture19", "Mixture20","Mixture41", "Mixture42"]
```