// Compute accuracy
float
subgraph_accuracy (subgraph * sg)
{
  float Acc = 0.0f, **error_matrix = NULL, error = 0.0f;
  int i, *nclass = NULL, nlabels = 0;

  error_matrix = (float **) calloc (sg->nlabels + 1, sizeof (float *));
  for (i = 0; i <= sg->nlabels; i++)
    error_matrix[i] = (float *) calloc (2, sizeof (float));

  nclass = AllocIntArray (sg->nlabels + 1);

  for (i = 0; i < sg->node_n; i++)
    {
      nclass[sg->node[i].label_true]++;
    }

  for (i = 0; i < sg->node_n; i++)
    {
      if (sg->node[i].label_true != sg->node[i].label)
        {
          error_matrix[sg->node[i].label_true][1]++;
          error_matrix[sg->node[i].label][0]++;
        }
    }

  for (i = 1; i <= sg->nlabels; i++)
    {
      if (nclass[i] != 0)
        {
          error_matrix[i][1] /= (float) nclass[i];
          error_matrix[i][0] /= (float) (sg->node_n - nclass[i]);
          nlabels++;
        }
    }

  for (i = 1; i <= sg->nlabels; i++)
    {
      if (nclass[i] != 0)
        error += (error_matrix[i][0] + error_matrix[i][1]);
    }

  Acc = 1.0 - (error / (2.0 * nlabels));

  for (i = 0; i <= sg->nlabels; i++)
    free (error_matrix[i]);
  free (error_matrix);
  free (nclass);

  return (Acc);
}

// Compute the confusion matrix
int **
subgraph_confusion_matrix (subgraph * sg)
{
  int **confusion_matrix = NULL, i;

  confusion_matrix = (int **) calloc ((sg->nlabels + 1), sizeof (int *));
  for (i = 1; i <= sg->nlabels; i++)
    confusion_matrix[i] = (int *) calloc ((sg->nlabels + 1), sizeof (int));

  for (i = 0; i < sg->node_n; i++)
    confusion_matrix[sg->node[i].label_true][sg->node[i].label]++;

  return confusion_matrix;
}


