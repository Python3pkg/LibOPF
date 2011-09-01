# code

cimport libopf_py
import numpy as np
cimport numpy as np

cdef class OPF:

  cdef libopf_py.subgraph * sg
  cdef bint supervised

  def __cinit__(self):
      self.sg = NULL
      self.supervised = True

  def __dealloc__(self):
    if self.sg is not NULL:
      libopf_py.subgraph_destroy (&self.sg)

  def fit (self,
          np.ndarray[np.float32_t, ndim=2, mode='c'] X,
          np.ndarray[np.int32_t,   ndim=1, mode='c'] Y = None,
          learning="default", metric="euclidian",
          bint use_precomputed_distance=False, double split=0.2):

      cdef np.ndarray[np.float32_t, ndim=2, mode='c'] X_train, X_eval
      cdef np.ndarray[np.int32_t, ndim=1, mode='c'] Y_train, Y_eval
      cdef int train_size, eval_size
      eval_size = 0

      d = {
            "euclidian"          : libopf_py.EUCLIDIAN,
            "log_euclidian"      : libopf_py.LOG_EUCLIDIAN,
            "chi_square"         : libopf_py.CHI_SQUARE,
            "manhattan"          : libopf_py.MANHATTAN,
            "canberra"           : libopf_py.CANBERRA,
            "squared_chord"      : libopf_py.SQUARED_CHORD,
            "squared_chi_square" : libopf_py.SQUARED_CHI_SQUARE,
            "bray_curtis"        : libopf_py.BRAY_CURTIS
          }

      if X.shape[0] != Y.shape[0]:
        raise Exception("Shape mismatch")

      if Y != None:
        self.supervised = True
      else:
        self.supervised = False

      if self.supervised: #supervised
        if learning not in ("default", "iterative", "agglomerative"):
          raise Exception("Invalid training mode")

        #split training set
        if learning in ("iterative", "agglomerative"):
          train_size = int(X.shape[0] * split)
          eval_size = X.shape[0] - train_size
        else:
          train_size = X.shape[0]
      else: #unsupervised
        train_size = X.shape[0]

      self.sg = libopf_py.subgraph_create (<int>train_size)
      if self.sg == NULL:
        raise MemoryError("Seems we've run out of of memory")

      if self.supervised:
        if learning in ("iterative", "agglomerative"):
          X_train, X_eval = X[:train_size], X[train_size:]
          Y_train, Y_eval = Y[:train_size], Y[train_size:]
          if not libopf_py.subgraph_set_data (self.sg, <float*>X_train.data,
                                              <int*>Y_train.data, <int>X_train.shape[1]):
            raise MemoryError("Seems we've run out of of memory")
        else:
          if not libopf_py.subgraph_set_data (self.sg, <float*>X.data, <int*>Y.data, <int>X.shape[1]):
            raise MemoryError("Seems we've run out of of memory")
      else:
        if not libopf_py.subgraph_set_data (self.sg, <float*>X.data, NULL, <int>X.shape[1]):
          raise MemoryError("Seems we've run out of of memory")

      if use_precomputed_distance:
        libopf_py.subgraph_precompute_distance (self.sg, NULL, d[metric])
      else:
        libopf_py.subgraph_set_metric (self.sg, d[metric])

      if self.supervised:
        if learning == "default":
          libopf_py.supervised_train (self.sg)
        elif learning == "iterative":
          libopf_py.supervised_train_iterative (self.sg, <float*>X_eval.data,
                                                <int*>Y_eval.data, <int>eval_size)
        elif learning == "agglomerative":
          libopf_py.supervised_train_agglomerative (self.sg, <float*>X_eval.data,
                                                    <int*>Y_eval.data, <int>eval_size)
      else:
        libopf_py.subgraph_best_k_min_cut (self.sg, 1, 10)
        libopf_py.unsupervised_clustering (self.sg)

  def predict(self, np.ndarray[np.float32_t, ndim=2, mode='c'] X):

    cdef np.ndarray[np.int32_t, ndim=1, mode='c'] labels
    labels = np.empty(X.shape[0], dtype=np.int32)

    if self.supervised == None:
      raise Exception ("Not fitted!")

    if self.supervised:
      libopf_py.supervised_classify (self.sg, <float*>X.data, <int>X.shape[0], <int*>labels.data)
    else:
      libopf_py.unsupervised_knn_classify (self.sg, <float*>X.data, <int>X.shape[0], <int*>labels.data)

    return labels
