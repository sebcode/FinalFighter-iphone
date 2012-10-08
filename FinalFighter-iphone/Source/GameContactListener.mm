
#import "GameContactListener.h"
#import "GameUserDataCppInterface.h"

GameContactListener::GameContactListener() : _contacts()
{
}

GameContactListener::~GameContactListener()
{
}

void GameContactListener::BeginContact(b2Contact* contact)
{
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    GameContact myContact = {
        contact->GetFixtureA()->GetBody(),
        contact->GetFixtureB()->GetBody(),
        contact->GetFixtureA(),
        contact->GetFixtureB(),
        YES
    };
    _contacts.push_back(myContact);
}

void GameContactListener::EndContact(b2Contact* contact)
{
    GameContact myContact = {
        contact->GetFixtureA()->GetBody(),
        contact->GetFixtureB()->GetBody(),
        contact->GetFixtureA(),
        contact->GetFixtureB(),
        NO
    };
    _contacts.push_back(myContact);
}

void GameContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
    b2Fixture *fixtureA = contact->GetFixtureA();
    if (!fixtureA) {
        return;
    }
    
    b2Fixture *fixtureB = contact->GetFixtureB();
    if (!fixtureB) {
        return;
    }
    
    b2Body *bodyA = fixtureA->GetBody();
    if (!bodyA) {
        return;
    }
    
    b2Body *bodyB = fixtureB->GetBody();
    if (!bodyB) {
        return;
    }
    
    void *userDataA = bodyA->GetUserData();
    if (!userDataA) {
        return;
    }

    void *userDataB = bodyB->GetUserData();
    if (!userDataB) {
        return;
    }
    
    if (!CheckCollision(userDataA, userDataB)) {
        contact->SetEnabled(false);
    }
}
