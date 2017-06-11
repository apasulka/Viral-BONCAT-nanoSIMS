#' generate activity distribution
#' @param particles starting particles (i.e. subset of negative control)
#' @param n_active number of particles active
#' @param avg_subs average number of Met substitutions
#' @param n_sites number of potential substitution sites (as long n > ~400, exact number does not change the probability distribution significantely)
#' @param dRG_per_sub average change in RG per substitution
#' @param dRG_per_sub_range +/- percent of RG per substitution (0-100)
#' @export
#' @return vector of activity values for the particles
generate_activity_distribution <- function(particles, n_active, avg_subs, n_sites = 1000, dRG_per_sub, dRG_per_sub_range) {
  stopifnot(n_active <= length(particles))
  n_particles <- length(particles)
  active_idx <- sample(1:n_particles, n_active)
  n_subs <- rbinom(n_active, size = n_sites, p = avg_subs/n_sites)
  dRG <- runif(n_active, min = dRG_per_sub - dRG_per_sub_range/100 * dRG_per_sub, max = dRG_per_sub + dRG_per_sub_range/100 * dRG_per_sub)
  particles[active_idx] <- particles[active_idx] + dRG * n_subs
  return(particles)
}


#' bootstrap data to calculate confidence intervals
#' based on the statistical model of whether values in a are larger than b 
#' @param a active distribution to test
#' @param b inactive distribution to test
#' @param B number of boot strap tests
#' @param alpha confidence interval
#' @param a.noise that affects the active distribution (default is no noise)
#' @param b.noise that affects the inactive distribution (default is no noise)
#' @export
calculate_active_cells <- function(a, b, B = 1000, alpha = 0.95, a.noise = function(n) rep(0,n), b.noise = function(n) rep(0,n)) {
  n <- min(length(a), length(b)) # make sure same number of samples from both conditions
  boot.stat <- numeric(B)
  a_shift <- a.noise(B)
  b_shift <- b.noise(B)
  for (i in 1:B) {
    a.boot <- sample(a, size = n, replace = TRUE) + a_shift[i]
    b.boot <- sample(b, size = n, replace = TRUE) + b_shift[i]
    boot.stat[i] <- (sum(a.boot>b.boot) - sum(b.boot>a.boot))/n
  }
  ci <- setNames(quantile(boot.stat,c( (1-alpha)/2, (1+alpha)/2)), c("lci", "uci"))
  return(c(active = mean(boot.stat), ci[1], ci[2]))
}
