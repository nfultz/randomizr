#' Stratified and Clustered Random Sampling
#'
#' A random sampling procedure in which units are sampled as clusters and clusters are nested within strata.
#'
#' @param strata A vector of length N that indicates which stratum each unit belongs to.
#' @param clusters A vector of length N that indicates which cluster each unit belongs to.
#' @param prob Use for a design in which either floor(N_clusters_stratum*prob) or ceiling(N_clusters_stratum*prob) clusters are sampled within each stratum. The probability of being sampled is exactly prob because with probability 1-prob, floor(N_clusters_stratum*prob) clusters will be sampled and with probability prob, ceiling(N_clusters_stratum*prob) clusters will be sampled. prob must be a real number between 0 and 1 inclusive. (optional)
#' @param prob_unit Must of be of length N. tapply(prob_unit, blocks, unique) will be passed to \code{strata_prob}.
#' @param n Use for a design in which the scalar n describes the fixed number of units to sample in each stratum. This number does not vary across strata.
#' @param n_unit Must be of length N. tapply(m_unit, blocks, unique) will be passed to \code{strata_n}.
#' @param strata_n Use for a design in which strata_n describes the number of units to sample within each stratum.
#' @param strata_prob Use for a design in which strata_prob describes the probability of being sampled within each stratum. Differs from prob in that the probability of being sampled can vary across strata.
#' @param check_inputs logical. Defaults to TRUE.
#'
#' @return A numeric vector of length N that indicates if a unit is sampled (1) or not (0).
#'
#' @examples
#' clusters <- rep(letters, times = 1:26)
#'
#' strata <- rep(NA, length(clusters))
#' strata[clusters %in% letters[1:5]] <- "stratum_1"
#' strata[clusters %in% letters[6:10]] <- "stratum_2"
#' strata[clusters %in% letters[11:15]] <- "stratum_3"
#' strata[clusters %in% letters[16:20]] <- "stratum_4"
#' strata[clusters %in% letters[21:26]] <- "stratum_5"
#'
#' table(strata, clusters)
#'
#' S <- strata_and_cluster_rs(strata = strata,
#'                           clusters = clusters)
#'
#' table(S, strata)
#' table(S, clusters)
#'
#'
#' S <- strata_and_cluster_rs(clusters = clusters,
#'                            strata = strata,
#'                            prob = .5)
#'
#' table(S, clusters)
#' table(S, strata)
#'
#' S <- strata_and_cluster_rs(clusters = clusters,
#'                            strata = strata,
#'                            strata_n = c(2, 3, 2, 3, 2))
#'
#' table(S, clusters)
#' table(S, strata)
#'
#' S <- strata_and_cluster_rs(clusters = clusters,
#'                            strata = strata,
#'                            strata_prob = c(.1, .2, .3, .4, .5))
#'
#' table(S, clusters)
#' table(S, strata)
#'
#'
#' @export
strata_and_cluster_rs <-
  function(strata = NULL,
           clusters = NULL,
           prob = NULL,
           prob_unit = NULL,
           n = NULL,
           n_unit = NULL,
           strata_n = NULL,
           strata_prob = NULL,
           check_inputs = TRUE) {
    if (check_inputs)
      .invoke_check(check_samplr_arguments_new)
    
    
    # Setup: obtain unique clusters
    n_per_clust <- tapply(clusters, clusters, length)
    
    # get the stratum for each cluster
    clust_strata <- tapply(strata, clusters, unique)
    
    if(!is.null(prob_unit)){
      strata_prob <- tapply(prob_unit, strata, unique)
    }
    
    if(!is.null(n_unit)){
      strata_n <- tapply(n_unit, strata, unique)
    }
    
    # Conduct random assignment at cluster level
    S_clust <- strata_rs(
      strata = clust_strata,
      prob = prob,
      n = n,
      strata_n = strata_n,
      strata_prob = strata_prob,
      check_inputs = check_inputs
    )
    
    # back up to the individual level, maintaining original ordering
    assignment <- rep(S_clust, n_per_clust)
    assignment <-
      assignment[order(unlist(split(seq_along(clusters), clusters), 
                              FALSE, FALSE))]
    return(assignment)
  }

#' Inclusion Probabilities: Stratified and Clustered Random Sampling
#'
#' @inheritParams strata_and_cluster_rs
#'
#' @return A vector length N indicating the probability of being sampled.
#'
#' @examples
#'
#' clusters <- rep(letters, times = 1:26)
#'
#' strata <- rep(NA, length(clusters))
#' strata[clusters %in% letters[1:5]] <- "stratum_1"
#' strata[clusters %in% letters[6:10]] <- "stratum_2"
#' strata[clusters %in% letters[11:15]] <- "stratum_3"
#' strata[clusters %in% letters[16:20]] <- "stratum_4"
#' strata[clusters %in% letters[21:26]] <- "stratum_5"
#'
#' table(strata, clusters)
#'
#' probs <- strata_and_cluster_rs_probabilities(strata = strata,
#'                                          clusters = clusters)
#'
#' table(probs, strata)
#' table(probs, clusters)
#'
#'
#' probs <- strata_and_cluster_rs_probabilities(clusters = clusters,
#'                                          strata = strata,
#'                                          prob = .5)
#'
#' table(probs, clusters)
#' table(probs, strata)
#'
#' probs <- strata_and_cluster_rs_probabilities(clusters = clusters,
#'                                          strata = strata,
#'                                          strata_n = c(2, 3, 2, 3, 2))
#'
#' table(probs, clusters)
#' table(probs, strata)
#'
#' probs <- strata_and_cluster_rs_probabilities(clusters = clusters,
#'                                          strata = strata,
#'                                          strata_prob = c(.1, .2, .3, .4, .5))
#'
#' table(probs, clusters)
#' table(probs, strata)
#'
#'
#' @export
strata_and_cluster_rs_probabilities <-
  function(strata = NULL,
           clusters = NULL,
           prob = NULL,
           prob_unit = NULL,
           n = NULL,
           n_unit = NULL,
           strata_n = NULL,
           strata_prob = NULL,
           check_inputs = TRUE) {
    if (check_inputs)
      .invoke_check(check_samplr_arguments_new)
    
    
    # Setup: obtain unique clusters
    n_per_clust <- tapply(clusters, clusters, length)
    
    # get the stratum for each cluster
    clust_strata <- tapply(strata, clusters, unique)
    
    if(!is.null(prob_unit)){
      strata_prob <- tapply(prob_unit, strata, unique)
    }
    
    if(!is.null(n_unit)){
      strata_n <- tapply(n_unit, strata, unique)
    }
    
    probs_clust <- strata_rs_probabilities(
      strata = clust_strata,
      prob = prob,
      n = n,
      strata_n = strata_n,
      strata_prob = strata_prob,
      check_inputs = check_inputs
    )
    
    prob_vec <- rep(probs_clust, n_per_clust)
    prob_vec <-
      prob_vec[order(unlist(split(seq_along(clusters), clusters), FALSE, FALSE))]
    return(prob_vec)
  }
