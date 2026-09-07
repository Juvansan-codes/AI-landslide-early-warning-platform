"""
Tests for the health check endpoint.
"""

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_check_returns_200():
    """Health endpoint should return 200 OK."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200


def test_health_check_response_body():
    """Health endpoint should return status and version."""
    response = client.get("/api/v1/health")
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert data["version"] == "0.1.0"
