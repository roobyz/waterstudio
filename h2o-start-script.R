# ###################################################################################
# Now that H2O is setup, lets test it out!
library(h2o)

# initialize h2o on all cores with default settings
localH2O = h2o.init(nthreads=-1)

# initialize h2o on specified server/port with all cores and specified memory limit.
localH2O = h2o.init(ip = 'localhost', port = 54321, nthreads=-1, max_mem_size = '32g')

# Finally, let's run a demo to see H2O at work.
demo(h2o.kmeans)
demo(h2o.glm)

