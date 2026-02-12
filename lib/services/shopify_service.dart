
import 'package:graphql_flutter/graphql_flutter.dart';

class ShopifyService {
  static final HttpLink httpLink = HttpLink(
    'https://f5ab0c-4.myshopify.com/api/2023-04/graphql.json',
    defaultHeaders: {
      'X-Shopify-Storefront-Access-Token': 'e8bdd981f138c518c73e28deb785417e',
    },
  );

  static final GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  );

  static const String getStoreDataQuery = r"""
    query getStoreData {
      products(first: 20) {
        edges {
          node {
            id
            title
            description
            images(first: 1) {
              edges {
                node { url }
              }
            }
            variants(first: 1) {
              edges {
                node { 
                  id
                  price { amount currencyCode } 
                }
              }
            }
          }
        }
      }
      collections(first: 10) {
        edges {
          node {
            id
            title
            products(first: 20) {
              edges {
                node { 
                  id
                  title
                  images(first: 1) {
                    edges {
                      node { url }
                    }
                  }
                  variants(first: 1) {
                    edges {
                      node { 
                        id
                        price { amount currencyCode } 
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  """;

  static const String cartCreateMutation = r"""
    mutation cartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart {
          id
          checkoutUrl
        }
        userErrors {
          field
          message
        }
      }
    }
  """;
}