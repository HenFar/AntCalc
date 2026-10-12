"""Automatic generation of Kira integral families covering an antenna's denominator signatures."""

from .cover import choose_cover, first_fit_routing, minimum_cover, numerator_cost, order_families
from .kira_yaml import (
    build_family,
    cut_momenta,
    family_name,
    invariant_subset,
    propagator_momentum,
    render_yaml,
    write_integralfamilies,
)
from .pipeline import (
    GenerationResult,
    check_coverage,
    check_reconstruction,
    compare_with_handwritten,
    generate_families,
    prepare_families,
)
from .signatures import (
    candidate_families,
    count_propagators,
    denominator_signature,
    find_dependent_signatures,
    group_by_signature,
    is_independent,
    load_monomials,
    numerator_powers,
)

__all__ = [
    "GenerationResult", "generate_families", "prepare_families", "check_coverage", "check_reconstruction",
    "compare_with_handwritten", "load_monomials", "denominator_signature", "numerator_powers",
    "group_by_signature", "count_propagators", "is_independent", "find_dependent_signatures",
    "candidate_families", "minimum_cover", "numerator_cost", "choose_cover", "order_families",
    "first_fit_routing", "invariant_subset", "propagator_momentum", "cut_momenta",
    "build_family", "family_name", "render_yaml", "write_integralfamilies",
]
