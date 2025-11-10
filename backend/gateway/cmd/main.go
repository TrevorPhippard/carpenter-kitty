package main

import (
	"log"
	"net/http"

	pbconn "gateway/service"

	"google.golang.org/grpc"

	"gateway/graph"

	"github.com/99designs/gqlgen/codegen/testserver/compliant-int/generated-compliant-strict"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
)

func main() {
	// --- gRPC connections ---
	userConn, err := grpc.Dial("user-service:50051", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	postConn, err := grpc.Dial("post-service:50052", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	// connConn, err := grpc.Dial("connections-service:50053", grpc.WithInsecure())
	// if err != nil {
	// 	log.Fatal(err)
	// }

	// --- gRPC clients ---
	userClient := pbconn.NewUserServiceClient(userConn)
	postClient := pbconn.NewPostServiceClient(postConn)
	// connectionsClient := pbconn.NewConnectionsServiceClient(connConn)

	// --- Resolver instance ---
	resolver := &graph.Resolver{
		UserClient: userClient,
		PostClient: postClient,
		// ConnectionsClient: connectionsClient,
	}

	// --- GraphQL Server ---
	srv := handler.NewDefaultServer(generated.NewExecutableSchema(generated.Config{Resolvers: resolver}))

	http.Handle("/", playground.Handler("GraphQL", "/query"))
	http.Handle("/query", srv)

	log.Println("Gateway running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
